package th.go.moph.covidfree;

import COSE.CoseException;

import java.security.PublicKey;

public interface CertificateProvider {
    PublicKey provideKey(byte[] kid, String issuer) throws CoseException;
}