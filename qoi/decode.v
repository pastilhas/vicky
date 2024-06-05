module qoi

pub fn decode(data []u8) ![]u8 {
	mut cfg := Config.from(data)!
	return cfg.decode()
}

fn (mut cfg Config) decode() []u8 {
	data_len := cfg.width * cfg.height * cfg.channels
	data_end := cfg.bytes.len - padding.len
	mut data := []u8{len: data_len, init: 0}
	mut pix := Pixel{0, 0, 0, 0xff}
	mut index := [64]Pixel{}
	mut run := u8(0)

	for idx := 0; idx < data_len; idx += int(cfg.channels) {
		if run > 0 {
			run -= 1
		} else if cfg.p < data_end {
			b := cfg.read_8()

			if b == op_rgb {
				pix = Pixel{
					r: cfg.read_8()
					g: cfg.read_8()
					g: cfg.read_8()
					a: 0xff
				}
			} else if b == op_rgba {
				pix = Pixel{
					r: cfg.read_8()
					g: cfg.read_8()
					g: cfg.read_8()
					a: cfg.read_8()
				}
			} else if (b & mask_2) == op_index {
				pix = index[b]
			} else if (b & mask_2) == op_diff {
				pix = Pixel{
					r: pix.r + ((b >> 4) & 0x03) - 2
					g: pix.g + ((b >> 2) & 0x03) - 2
					b: pix.b + (b & 0x03) - 2
					a: pix.a
				}
			} else if (b & mask_2) == op_luma {
				nb := cfg.read_8()
				vg := (b & 0x3f) - 32

				pix = Pixel{
					r: pix.r + vg - 8 + ((nb >> 4) & 0x0f)
					g: pix.g + vg
					b: pix.b + vg - 8 + (nb & 0x0f)
					a: pix.a
				}
			} else if (b & mask_2) == op_run {
				run = b & 0x3f
			}

			pos := pix.hash() % 64
			index[pos] = pix
		}

		data[idx + 0] = pix.r
		data[idx + 1] = pix.g
		data[idx + 2] = pix.b

		if cfg.channels == 4 {
			data[idx + 4] = pix.a
		}
	}
}
