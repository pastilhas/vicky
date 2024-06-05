module qoi

struct Config {
mut:
	width      u32
	height     u32
	channels   u8
	colorspace u8
	p          int
	bytes      []u8
}

fn Config.new(w u32, h u32, ch u8, cs u8) !Config {
	if w == 0 || h == 0 {
		return error('Image has invalid size ${w}x${h}')
	}

	if ch < 3 || ch > 4 {
		return error('Image has invalid channels ${ch}')
	}

	if cs > 1 {
		return error('Image has invalid colorspace ${cs}')
	}

	if w * h >= max_pixels {
		return error('Image of size ${w * h} is bigger than limit ${max_pixels}')
	}

	return Config{
		width: w
		height: h
		channels: ch
		colorspace: cs
		bytes: []u8{len: w * h * (ch + 1) + header_size + padding.len, init: 0}
	}
}

fn Config.from(bytes []u8) !Config {
	mut cfg := Config{
		bytes: bytes
	}

	if bytes.len < header_size {
		return error('Data does not contain a header')
	}

	mag := cfg.read_32()
	cfg.width = cfg.read_32()
	cfg.height = cfg.read_32()
	cfg.channels = cfg.read_8()
	cfg.colorspace = cfg.read_8()

	if mag != magic {
		return error('Invalid magic number')
	}

	if cfg.width == 0 || cfg.height == 0 {
		return error('Invalid image size ${cfg.width}x${cfg.height}')
	}

	if cfg.width * cfg.height >= max_pixels {
		return error('Image of size ${w * h} is bigger than limit ${max_pixels}')
	}

	if cfg.channels < 3 || cfg.channels > 4 {
		return error('Invalid channels ${cfg.channels}')
	}

	if cfg.colorspace > 1 {
		return error('Invalid colorspace ${cfg.colorspace}')
	}

	len := cfg.width * cfg.height * (cfg.channels + 1) + header_size + padding.len
	if len != bytes.len {
		return error('Invalid data size ${bytes.len} <> ${len}')
	}

	return cfg
}

fn (mut cfg Config) write_32(v u32) {
	cfg.bytes[cfg.p + 0] = u8((v >> 24) & 0x000000ff)
	cfg.bytes[cfg.p + 1] = u8((v >> 16) & 0x000000ff)
	cfg.bytes[cfg.p + 2] = u8((v >> 8) & 0x000000ff)
	cfg.bytes[cfg.p + 3] = u8(v & 0x000000ff)
	cfg.p += 4
}

fn (mut cfg Config) write_8(v u8) {
	cfg.bytes[cfg.p] = u8(v & 0x000000ff)
	cfg.p += 1
}

fn (mut cfg Config) read_32() u32 {
	a := u32(cfg.bytes[cfg.p + 0])
	b := u32(cfg.bytes[cfg.p + 1])
	c := u32(cfg.bytes[cfg.p + 2])
	d := u32(cfg.bytes[cfg.p + 3])
	cfg.p += 4
	return (a << 24) | (b << 16) | (c << 8) | d
}

fn (mut cfg Config) read_8() u8 {
	a := cfg.bytes[cfg.p]
	cfg.p += 1
	return a
}
