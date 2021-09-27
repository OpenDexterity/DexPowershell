class DexDictionaryBlock {
    [UInt32]$BlockNumber
    [UInt16]$BlockType
    [UInt32]$StartOffset
    [UInt32]$Size
    [UInt32]$UnusedSpace
}

class DexDictionaryBlockTable {
    [string]$Path
    [DexDictionaryBlock[]]$Blocks
    [UInt32]$TableOffset
    [UInt32]$TableLength
}