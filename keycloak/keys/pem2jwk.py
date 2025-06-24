import base64
import sys

def b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode('ascii')

def int_to_bytes(i: int) -> bytes:
    length = (i.bit_length() + 7) // 8
    return i.to_bytes(length, byteorder='big')

def parse_pem_public_key(pem_file):
    with open(pem_file, 'r') as f:
        lines = f.read().strip().splitlines()
    # Eltávolítjuk a PEM fejléceket
    b64 = ''.join(line for line in lines if not line.startswith('---'))
    der = base64.b64decode(b64)
    return der

def der_to_rsa_components(der_bytes):
    # Egyszerű DER parser csak az RSA publikus kulcshoz (szigorúan az ASN.1 szerkezethez)
    # Alapból a DER struktúra az alábbi:
    # SEQUENCE {
    #   SEQUENCE {
    #     OID rsaEncryption
    #     NULL
    #   }
    #   BIT STRING {
    #     SEQUENCE {
    #       modulus INTEGER
    #       exponent INTEGER
    #     }
    #   }
    # }
    # Kicsit trükkös, így manuálisan fogjuk kinyerni.

    # Importálunk pyasn1-t? Nem, nincs külső csomag, így egyszerűen:
    # Egy minimális DER parser (feltételezve, hogy a kulcs standard formátumú)

    # A publikusan használatos PEM "SubjectPublicKeyInfo" formátumot dekódoljuk:
    from struct import unpack

    data = der_bytes
    pos = 0

    def read_length(data, pos):
        length = data[pos]
        pos += 1
        if length & 0x80:
            num_bytes = length & 0x7f
            length = 0
            for _ in range(num_bytes):
                length = (length << 8) + data[pos]
                pos += 1
        return length, pos

    def expect_byte(data, pos, byte):
        if data[pos] != byte:
            raise ValueError(f"Expected byte 0x{byte:02x} at pos {pos}, got 0x{data[pos]:02x}")
        return pos + 1

    # Olvassuk az első SEQUENCE (0x30)
    pos = expect_byte(data, pos, 0x30)
    length, pos = read_length(data, pos)
    seq_end = pos + length

    # Második SEQUENCE (0x30)
    pos = expect_byte(data, pos, 0x30)
    length, pos = read_length(data, pos)
    pos += length  # átugorjuk az OID és NULL részt

    # BIT STRING (0x03)
    pos = expect_byte(data, pos, 0x03)
    length, pos = read_length(data, pos)

    # Egy byte a "unused bits" számát jelzi a bitstringben (általában 0)
    unused_bits = data[pos]
    pos += 1
    if unused_bits != 0:
        raise ValueError("Unexpected unused bits in BIT STRING")

    # Ezután SEQUENCE (0x30) a kulcs maga
    pos = expect_byte(data, pos, 0x30)
    length, pos = read_length(data, pos)

    # INTEGER modulus (0x02)
    pos = expect_byte(data, pos, 0x02)
    length, pos = read_length(data, pos)
    modulus = data[pos:pos+length]
    pos += length

    # INTEGER exponent (0x02)
    pos = expect_byte(data, pos, 0x02)
    length, pos = read_length(data, pos)
    exponent = data[pos:pos+length]
    pos += length

    # modulus és exponent most bytes, konvertáljuk base64url-ra
    return modulus, exponent

def main():
    if len(sys.argv) != 2:
        print("Használat: python3 pem2jwk.py public.pem")
        sys.exit(1)

    pem_file = sys.argv[1]

    der = parse_pem_public_key(pem_file)
    modulus, exponent = der_to_rsa_components(der)

    n = b64url_encode(modulus)
    e = b64url_encode(exponent)

    jwk = {
        "kty": "RSA",
        "alg": "RS256",
        "use": "sig",
        "n": n,
        "e": e
    }

    import json
    print(json.dumps(jwk, indent=2))

if __name__ == "__main__":
    main()
