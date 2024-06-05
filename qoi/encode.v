module qoi

pub fn encode(data []u8, w u32, h u32, ch u8, cs u8) ![]u8 {
	if data.len != (w * h * u32(ch)) {
		return error('Invalid data size ${data.len} <> ${(w * h * u32(ch))}')
	}

	mut cfg := Config.new(w, h, ch, cs)!
	return cfg.encode(data)
}
