module qoi

pub fn (cfg Config) encode(data []u8, mut len &int) ![]u8 {
	if cfg.width == 0 || cfg.height == 0 {
		return error('Image has invalid size ${cfg.width}x${cfg.height}')
	}

	if cfg.width * cfg.height >= max_pixels {
		return error('Image of size ${cfg.width * cfg.height} is bigger than limit ${max_pixels}')
	}

	max_size := cfg.width * cfg.height * (u32(cfg.channels) + 1) + header_size + padding.len

	mut p := 0
	mut bytes := []u8{len: max_size, init: 0}

	// Write header
	write_32(mut bytes, mut p, magic)
	write_32(mut bytes, mut p, cfg.width)
	write_32(mut bytes, mut p, cfg.height)
	write_8(mut bytes, mut p, u8(cfg.channels))
	write_8(mut bytes, mut p, u8(cfg.colorspace))

	// Util vars
	data_len := cfg.width * cfg.height * u32(cfg.channels)
	data_end := data_len - u32(cfg.channels)
	mut pre_pix := Pixel{0, 0, 0, 0xff}
	mut index := [64]Pixel{}
	mut run := u8(0)

	for idx := 0; idx < data_len; idx += int(cfg.channels) {
		pix := Pixel{
			r: data[idx + 0]
			g: data[idx + 1]
			b: data[idx + 2]
			a: if cfg.channels == Channels.rgba {
				data[idx + 3]
			} else {
				0xff
			}
		}

		if pix.value == pre_pix.value {
			run += 1

			if run == 62 || idx == data_end {
				write_8(mut bytes, mut p, op_run | (run - 1))
				run = 0
			}

			pre_pix = pix
			continue
		}

		if run > 0 { // if was in run write it
			write_8(mut bytes, mut p, op_run | run - 1)
			run = 0
		}

		pos := hash(pix) % 64
		if index[pos].value == pix.value { // if pixel found before, point
			write_8(mut bytes, mut p, op_index | u8(pos))
		} else {
			index[pos] = pix

			if pix.a == pre_pix.a {
				dr := int(pix.r) - pre_pix.r
				dg := int(pix.g) - pre_pix.g
				db := int(pix.b) - pre_pix.b

				dgr := dr - dg
				dgb := db - dg

				if dr > -3 && dr < 2 && dg > -3 && dg < 2 && db > -3 && db < 2 {
					v := u8(u8(dr + 2) << 4) | (u8(dg + 2) << 2) | u8(db + 2)
					write_8(mut bytes, mut p, op_diff | v)
				} else if dgr > -9 && dgr < 8 && dg > -33 && dg < 32 && dgb > -9 && dgb < 8 {
					write_8(mut bytes, mut p, op_luma | u8(dg + 32))
					write_8(mut bytes, mut p, (u8(dgr + 8) << 4) | u8(dgb + 8))
				} else {
					write_8(mut bytes, mut p, op_rgb)
					write_8(mut bytes, mut p, pix.r)
					write_8(mut bytes, mut p, pix.g)
					write_8(mut bytes, mut p, pix.b)
				}
			} else {
				write_8(mut bytes, mut p, op_rgba)
				write_32(mut bytes, mut p, pix.value())
			}
		}

		pre_pix = pix
	}

	for q in padding {
		write_8(mut bytes, mut p, q)
	}

	unsafe {
		*len = p
	}
	return bytes
}
