module qoi

const op_index = u8(0x00)
const op_diff = u8(0x40)
const op_luma = u8(0x80)
const op_run = u8(0xc0)
const op_rgb = u8(0xfe)
const op_rgba = u8(0xff)
const mask_2 = u8(0xc0)
const magic = u32(0x716f6966)
const header_size = u32(14)
const max_pixels = u32(400_000_000)
const padding = [u8(0), 0, 0, 0, 0, 0, 0, 1]
