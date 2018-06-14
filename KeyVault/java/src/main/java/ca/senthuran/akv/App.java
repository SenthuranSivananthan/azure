package ca.senthuran.akv;

import com.microsoft.azure.keyvault.KeyVaultClient;
import com.microsoft.azure.keyvault.authentication.KeyVaultCredentials;
import com.microsoft.azure.keyvault.models.KeyBundle;
import com.microsoft.azure.keyvault.models.KeyOperationResult;
import com.microsoft.azure.keyvault.models.SecretBundle;
import com.microsoft.azure.keyvault.requests.CreateKeyRequest;
import com.microsoft.azure.keyvault.requests.CreateKeyRequest.Builder;
import com.microsoft.azure.keyvault.webkey.JsonWebKeyEncryptionAlgorithm;
import com.microsoft.azure.keyvault.webkey.JsonWebKeyType;

/**
 * If you create or import keys as HSM-protected, they are guaranteed to be
 * processed inside HSMs validated to FIPS 140-2 Level 2 or higher.
 * 
 * If you create or import keys as software-protected then they are processed
 * inside cryptographic modules validated to FIPS 140-2 Level 1 or higher.
 * 
 * RSA1_5 - RSAES-PKCS1-V1_5 [RFC3447] key encryption
 * 
 * RSA-OAEP - RSAES using Optimal Asymmetric Encryption Padding (OAEP)
 * [RFC3447], with the default parameters specified by RFC 3447 in Section
 * A.2.1. Those default parameters are using a hash function of SHA-1 and a mask
 * generation function of MGF1 with SHA-1.
 */
public class App {
	public static void main(String[] args) throws Exception {
		String applicationId = "";
		String applicationSecret = "";
		String vaultUrl = "https://myakv.vault.azure.net/";

		KeyVaultCredentials credentials = new ClientSecretKeyVaultCredential(applicationId, applicationSecret);

		// WrapAndUnwrap_RSA1_5(credentials, vaultUrl);
		// WrapAndUnwrap_RSA_OAEP(credentials, vaultUrl);
		EncryptAndDecrypt_RSA1_5(credentials, vaultUrl);
		EncryptAndDecrypt_RSA_OAEP(credentials, vaultUrl);
	}

	public static void GetSecret(KeyVaultCredentials credentials, String vaultUrl) {
		String secretName = "VMPassword";

		KeyVaultClient kvc = new KeyVaultClient(credentials);
		SecretBundle secret = kvc.getSecret(vaultUrl, secretName);

		System.out.println(secret.value());
	}

	public static void WrapAndUnwrap_RSA1_5(KeyVaultCredentials credentials, String vaultUrl) throws Exception {
		KeyVaultClient kvc = new KeyVaultClient(credentials);
		String mySecretData = "HelloWorld!";

		// create a key
		// if the key exists, then a new version is created
		Builder keyRequestBuilder = new Builder(vaultUrl, "SenthuranKey", JsonWebKeyType.RSA);
		CreateKeyRequest createKeyRequest = keyRequestBuilder.build();
		KeyBundle bundle = kvc.createKey(createKeyRequest);

		// wrap - software based key
		KeyOperationResult wrapResult = kvc.wrapKey(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA1_5, mySecretData.getBytes());
		byte[] wrappedData = wrapResult.result();

		// unwrap - software based key
		KeyOperationResult unwrapResult = kvc.unwrapKey(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA1_5, wrappedData);
		byte[] unwrappedData = unwrapResult.result();

		// show results
		System.out.println(new String(unwrappedData));
	}

	// Read:
	// https://security.stackexchange.com/questions/32050/what-specific-padding-weakness-does-oaep-address-in-rsa
	public static void WrapAndUnwrap_RSA_OAEP(KeyVaultCredentials credentials, String vaultUrl) throws Exception {
		KeyVaultClient kvc = new KeyVaultClient(credentials);
		String mySecretData = "HelloWorld!";

		// create a key
		// if the key exists, then a new version is created
		Builder keyRequestBuilder = new Builder(vaultUrl, "SenthuranKey", JsonWebKeyType.RSA);
		CreateKeyRequest createKeyRequest = keyRequestBuilder.build();
		KeyBundle bundle = kvc.createKey(createKeyRequest);

		// wrap - software based key
		KeyOperationResult wrapResult = kvc.wrapKey(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA_OAEP, mySecretData.getBytes());
		byte[] wrappedData = wrapResult.result();

		// unwrap - software based key
		KeyOperationResult unwrapResult = kvc.unwrapKey(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA_OAEP, wrappedData);
		byte[] unwrappedData = unwrapResult.result();

		// show results
		System.out.println(new String(unwrappedData));
	}

	public static void EncryptAndDecrypt_RSA1_5(KeyVaultCredentials credentials, String vaultUrl) throws Exception {
		KeyVaultClient kvc = new KeyVaultClient(credentials);
		String mySecretData = "HelloWorld!";

		// create a key
		// if the key exists, then a new version is created
		Builder keyRequestBuilder = new Builder(vaultUrl, "SenthuranKeyHSM", JsonWebKeyType.RSA_HSM);
		CreateKeyRequest createKeyRequest = keyRequestBuilder.build();
		KeyBundle bundle = kvc.createKey(createKeyRequest);

		// wrap - software based key
		KeyOperationResult wrapResult = kvc.encrypt(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA1_5, mySecretData.getBytes());
		byte[] wrappedData = wrapResult.result();

		// unwrap - software based key
		KeyOperationResult unwrapResult = kvc.decrypt(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA1_5, wrappedData);
		byte[] unwrappedData = unwrapResult.result();

		// show results
		System.out.println(new String(unwrappedData));
	}

	// Read:
	// https://security.stackexchange.com/questions/32050/what-specific-padding-weakness-does-oaep-address-in-rsa
	public static void EncryptAndDecrypt_RSA_OAEP(KeyVaultCredentials credentials, String vaultUrl) throws Exception {
		KeyVaultClient kvc = new KeyVaultClient(credentials);
		String mySecretData = "HelloWorld!";

		// create a key
		// if the key exists, then a new version is created
		Builder keyRequestBuilder = new Builder(vaultUrl, "SenthuranKeyHSM", JsonWebKeyType.RSA_HSM);
		CreateKeyRequest createKeyRequest = keyRequestBuilder.build();
		KeyBundle bundle = kvc.createKey(createKeyRequest);

		// wrap - software based key
		KeyOperationResult wrapResult = kvc.encrypt(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA_OAEP, mySecretData.getBytes());
		byte[] wrappedData = wrapResult.result();

		// unwrap - software based key
		KeyOperationResult unwrapResult = kvc.decrypt(bundle.keyIdentifier().identifier(),
				JsonWebKeyEncryptionAlgorithm.RSA_OAEP, wrappedData);
		byte[] unwrappedData = unwrapResult.result();

		// show results
		System.out.println(new String(unwrappedData));
	}
}
