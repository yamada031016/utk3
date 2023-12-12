// *	In-kernel dynamic memory management
const knlink = @import("knlink");
const inc_sys = @import("inc_sys");
const queue = inc_sys.queue;
const QUEUE = queue.QUEUE;

// * Memory allocation management information
// *  Order of members must not be changed because members are used
// *  with casting from MPLCB.
pub const IMACB = struct {
    memsz: SZ,
    // AreaQue for connecting each area where reserved pages are
    // divided Sort in ascending order of addresses in a page.
    // Do not sort between pages. */
    areaque: QUEUE,
    // FreeQue for connecting unused area in reserved pages
    // Sort from small to large free spaces. */
    freeque: QUEUE,
};

// * Compensation for aligning "&areaque" position to 2 bytes border
fn AlignIMACB(imacb: IMACB) *IMACB {
    return (@as(*IMACB, (@as(u32, imacb) & ~0x00000001)));
}

// * Minimum unit of subdivision
// *	The lower 1 bit of address is always 0
// *	because memory is allocated by ROUNDSZ.
// *	AreaQue uses the lower 1 bit for flag.
const ROUNDSZ = @sizeOf(QUEUE); // 8 bytes */

inline fn ROUND(sz: usize) u32 {
    return ((@as(u32, sz) + @as(u32, ROUNDSZ - 1)) & ~@as(u32, ROUNDSZ - 1));
}

// Minimum fragment size */
const MIN_FRAGMENT = ROUNDSZ * 2;

// * Maximum allocatable size (to check for parameter)
// INT_MAX == @max(isize)?
const MAX_ALLOCATE = knlink.INT_MAX & ~(ROUNDSZ - 1);

// * Adjusting the size which can be allocated
inline fn roundSize(sz: i32) i32 {
    if (sz < @as(i32, MIN_FRAGMENT)) {
        sz = @as(i32, MIN_FRAGMENT);
    }
    return @as(isize, (@as(u32, sz) + @as(u32, ROUNDSZ - 1)) & ~@as(u32, ROUNDSZ - 1));
}

// * Flag that uses the lower bits of AreaQue's 'prev'.
const AREA_USE = 0x00000001; // In-use */
const AREA_MASK = 0x00000001;

// fの型がわからんのでとりあえずu8にする。フラグっぽいし
// 返り値も適当にusize
inline fn setAreaFlag(q: QUEUE, f: u8) void {
    q.prev = @as(*QUEUE, (@as(u32, q.prev) | @as(u32, f)));
}
inline fn clrAreaFlag(q: QUEUE, f: u8) void {
    q.prev = @as(*QUEUE, (@as(u32, q.prev) & ~@as(u32, f)));
}
inline fn chkAreaFlag(q: QUEUE, f: u8) bool {
    return (@as(u32, q.prev) & @as(u32, f) != 0);
}

// x, y何かわからんから適当にu8
inline fn Mask(x: u8) usize {
    return @as(*QUEUE, @as(u32, x) & ~AREA_MASK);
}
inline fn Assign(x: u8, y: u8) void {
    x = @as(*QUEUE, ((@as(u32, x) & AREA_MASK) | @as(u32, y)));
}
// * Area size

//size返すっぽいしu8あればええやろ
inline fn AreaSize(aq: QUEUE) u8 {
    return (@as(*i8, aq.next - @as(*i8, aq + 1)));
}
inline fn FreeSize(fq: QUEUE) u8 {
    return (@as(i32, (fq + 1).prev));
}

pub const knl_imacb: *IMACB = undefined;

// * FreeQue search
// *	Search the free area whose size is equal to 'blksz',
// *	or larger than
// *      'blksz' but closest.
// *	If it does not exist, return '&imacb->freeque'.
pub fn knl_searchFreeArea(imacb: *IMACB, blksz: i32) *QUEUE {
    var q: *QUEUE = &imacb.freeque;

    // For area whose memory pool size is less than 1/4,
    // search from smaller size.
    // Otherwise, search from larger size. */
    if (blksz > imacb.memsz / 4) {
        // Search from larger size. */
        var fsz: i32 = 0;
        while (q.prev != &imacb.freeque) {
            q = q.prev;
            fsz = FreeSize(q);
            if (fsz <= blksz) {
                return if (fsz < blksz) q.next else q;
            }
        }
        return if (fsz >= blksz) q.next else q;
    } else {
        // Search from smaller size. */
        while (q.next != &imacb.freeque) {
            q = q.next;
            if (FreeSize(q) >= blksz) {
                break;
            }
        }
        return q;
    }
}

// * Registration of free area on FreeQue
// *	FreeQue is composed of 2 types: Queue that links the
// *	different size of areas by size and queue that links the
// *	same size of areas.
// *	freeque
// *	|
// *	|   +-----------------------+	    +-----------------------+
// *	|   | AreaQue		    |	    | AreaQue		    |
// *	|   +-----------------------+	    +-----------------------+
// *	*---> FreeQue Size order    |	    | EmptyQue		    |
// *	|   | FreeQue Same size   --------->| FreeQue Same size   ----->
// *	|   |			    |	    |			    |
// *	|   |			    |	    |			    |
// *	|   +-----------------------+	    +-----------------------+
// *	|   | AreaQue		    |	    | AreaQue		    |
// *	v   +-----------------------+	    +-----------------------+
pub fn knl_appendFreeArea(imacb: *IMACB, aq: *QUEUE) void {
    var size: SZ = AreaSize(aq);

    // Registration position search */
    //  Search the free area whose size is equal to 'blksz',
    // *  or larger than 'blksz' but closest.
    // *  If it does not exist, return '&imacb->freeque'.
    // */
    var fq: *QUEUE = knl_searchFreeArea(imacb, size);

    // Register */
    clrAreaFlag(aq, AREA_USE);
    if (fq != &imacb.freeque and FreeSize(fq) == size) {
        // FreeQue Same size */
        (aq + 2).next = (fq + 1).next;
        (fq + 1).next = aq + 2;
        (aq + 2).prev = fq + 1;
        if ((aq + 2).next != null) {
            (aq + 2).next.prev = aq + 2;
        }
        (aq + 1).next = null;
    } else {
        // FreeQue Size order */
        queue.QueInsert(aq + 1, fq);
        (aq + 2).next = null;
        (aq + 2).prev = @as(*QUEUE, size);
    }
}

// * Delete from FreeQue
pub fn knl_removeFreeQue(fq: *QUEUE) void {
    if (fq.next) { // FreeQue Size order */
        if ((fq + 1).next) |q| { // having FreeQue Same size */
            queue.QueInsert(q - 1, fq);
            q.prev = (fq + 1).prev;
        }
        queue.QueRemove(fq);
    } else { // FreeQue Same size */
        (fq + 1).prev.next = (fq + 1).next;
        if ((fq + 1).next) |q| {
            q.prev = (fq + 1).prev;
        }
    }
}

// * Register area
// *	Insert 'ent' just after 'que.'
pub fn knl_insertAreaQue(que: *QUEUE, ent: *QUEUE) void {
    ent.prev = que;
    ent.next = que.next;
    Assign(que.next.prev, ent);
    que.next = ent;
}

// * Delete area
pub fn knl_removeAreaQue(aq: *QUEUE) void {
    Mask(aq.prev).next = aq.next;
    Assign(aq.next.prev, Mask(aq.prev));
}

// if (comptime USE_IMALLOC) {
// Noinit(EXPORT IMACB *knl_imacb);
//  * Memory allocate
// EXPORT void* knl_Imalloc( SZ size )
// {
// 	QUEUE	*q, *aq, *aq2;
// 	UINT	imask;
//
// 	// If it is smaller than the minimum fragment size,
// 	   allocate the minimum size to it. */
// 	if( size <= 0 ) {
// 		return (void *)null;
// 	} else 	if ( size < MIN_FRAGMENT ) {
// 		size = MIN_FRAGMENT;
// 	} else {
// 		size = ROUND(size);
// 	}
//
// 	DI(imask);  // Exclusive control by interrupt disable */
//
// 	// Search FreeQue */
// 	q = knl_searchFreeArea(knl_imacb, size);
// 	if ( q == &(knl_imacb->freeque) ) {
// 		q = null; // Insufficient memory */
// 		goto err_ret;
// 	}
//
// 	// There is free area: Split from FreeQue once */
// 	knl_removeFreeQue(q);
//
// 	aq = q - 1;
//
// 	// If there are fragments smaller than the minimum fragment size,
// 	   allocate them also */
// 	if ( FreeSize(q) - size >= MIN_FRAGMENT + sizeof(QUEUE) ) {
//
// 		// Divide area into 2 */
// 		aq2 = (QUEUE*)((VB*)(aq + 1) + size);
// 		knl_insertAreaQue(aq, aq2);
//
// 		// Register remaining area to FreeQue */
// 		knl_appendFreeArea(knl_imacb, aq2);
// 	}
// 	setAreaFlag(aq, AREA_USE);
//
// err_ret:
// 	EI(imask);
//
// 	return (void *)q;
// }
//
// //
//  * Memory allocate  and clear
//  */
// EXPORT void* knl_Icalloc( SZ nmemb, SZ size )
// {
// 	SZ	sz = nmemb * size;
// 	void	*mem;
//
// 	mem = knl_Imalloc(sz);
// 	if ( mem == null ) {
// 		return null;
// 	}
//
// 	knl_memset(mem, 0, sz);
//
// 	return mem;
// }
//
//
// //
//  * Memory allocation size change
//  */
// EXPORT void* knl_Irealloc( void *ptr, SZ size )
// {
// 	void	*newptr;
// 	QUEUE	*aq;
// 	SZ	oldsz;
//
// 	if(size != 0) {
// 		newptr = knl_Imalloc(size);
// 		if(newptr == null) {
// 			return null;
// 		}
// 	} else {
// 		newptr = null;
// 	}
//
// 	if(ptr != null) {
// 		if(newptr != null) {
// 			aq = (QUEUE*)ptr - 1;
// 			oldsz = (SZ)AreaSize(aq);
// 			knl_memcpy(newptr, ptr, (size > oldsz)?oldsz:size);
// 		}
// 		knl_Ifree(ptr);
// 	}
//
// 	return newptr;
// }
//
//
// //
//  * Free memory
//  */
// EXPORT void  knl_Ifree( void *ptr )
// {
// 	QUEUE	*aq;
// 	UINT	imask;
//
// 	DI(imask);  // Exclusive control by interrupt disable */
//
// 	aq = (QUEUE*)ptr - 1;
// 	clrAreaFlag(aq, AREA_USE);
//
// 	if ( !chkAreaFlag(aq->next, AREA_USE) ) {
// 		// Merge with free area in after location */
// 		knl_removeFreeQue(aq->next + 1);
// 		knl_removeAreaQue(aq->next);
// 	}
//
// 	if ( !chkAreaFlag(aq->prev, AREA_USE) ) {
// 		// Merge with free area in front location */
// 		aq = aq->prev;
// 		knl_removeFreeQue(aq + 1);
// 		knl_removeAreaQue(aq->next);
// 	}
//
// 	knl_appendFreeArea(knl_imacb, aq);
//
// 	EI(imask);
// }
//  * IMACB Initialization
// LOCAL void initIMACB( void )
// {
// 	QueInit(&(knl_imacb->areaque));
// 	QueInit(&(knl_imacb->freeque));
// }
//
// //
//  * Imalloc initial setting
//  */
// EXPORT ER knl_init_Imalloc( void )
// {
// 	QUEUE	*top, *end;
//
// 	// Align top with 4 byte unit alignment for IMACB */
// 	knl_lowmem_top = (void *)(((UW)knl_lowmem_top + 3) & ~0x00000003UL);
// 	knl_imacb = (IMACB*)knl_lowmem_top;
// 	knl_lowmem_top = (void *)((UW)knl_lowmem_top + sizeof(IMACB));
//
// 	// Align top with 8 byte unit alignment */
// 	knl_lowmem_top = (void *)(((UW)knl_lowmem_top + 7) & ~0x00000007UL);
// 	top = (QUEUE*)knl_lowmem_top;
// 	knl_imacb->memsz = (W)((UW)knl_lowmem_limit - (UW)knl_lowmem_top - sizeof(QUEUE)*2);
//
// 	knl_lowmem_top = knl_lowmem_limit;  // Update memory free space */
//
// 	initIMACB();
//
// 	// Register on AreaQue */
// 	end = (QUEUE*)((VB*)top + knl_imacb->memsz) + 1;
// 	knl_insertAreaQue(&knl_imacb->areaque, end);
// 	knl_insertAreaQue(&knl_imacb->areaque, top);
// 	setAreaFlag(end, AREA_USE);
// 	setAreaFlag(&knl_imacb->areaque, AREA_USE);
//
// 	knl_appendFreeArea(knl_imacb, top);
//
// 	return E_OK;
// }
// }
