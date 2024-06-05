module qoi

struct Pixel {
	r u8
	g u8
	b u8
	a u8
}

fn Pixel.from(data []u8, idx int, len u8) Pixel {
	return Pixel{
		r: data[idx + 0]
		g: data[idx + 1]
		b: data[idx + 2]
		a: if len == 4 {
			data[idx + 3]
		} else {
			0xff
		}
	}
}

fn (pix Pixel) rgba() u32 {
	return (u32(pix.r) << 24) | (u32(pix.g) << 16) | (u32(pix.b) << 8) | u32(pix.a)
}

fn (pix1 Pixel) equals(pix2 Pixel) bool {
	return pix1.r == pix2.r && pix1.g == pix2.g && pix1.b == pix2.b && pix1.a == pix2.a
}

fn (pix Pixel) hash() int {
	return int(pix.r) * 3 + int(pix.g) * 5 + int(pix.b) * 7 + int(pix.a) * 11
}
