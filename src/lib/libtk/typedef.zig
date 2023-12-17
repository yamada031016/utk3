pub const ID = usize; //汎用ID
pub const MSEC = i32; //汎用時間
pub const SZ = i32; //汎用サイズ
pub const FN = isize; // Function code.
pub const RNO = isize; //待ちの数?
pub const ATR = u32; //オブジェクト/ハンドラの属性
pub const PRI = usize; //優先度
pub const TMO = i32; //タイムアウト時間の設定
pub const RELTIM = u32; //相対時間
pub const SYSTIM = struct {
    hi: i32, // Upper 32 bits
    lo: u32, // Lower 32 bits
};
pub const SYSTIM_U = i64; // system time (64 bits)

pub const TA_NULL = 0; // 特に属性がないことを示す
pub const TMO_POL = 0; //ポーリング
pub const TMO_FEVR = -1; //恒久的な待機
