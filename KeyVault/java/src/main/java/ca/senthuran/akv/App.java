package ca.senthuran.akv;

import com.microsoft.azure.keyvault.KeyVaultClient;
import com.microsoft.azure.keyvault.authentication.KeyVaultCredentials;
import com.microsoft.azure.keyvault.models.KeyBundle;
import com.microsoft.azure.keyvault.models.SecretBundle;
import com.microsoft.azure.keyvault.webkey.JsonWebKey;
import com.microsoft.rest.credentials.ServiceClientCredentials;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
    	String applicationId = "";
    	String applicationSecret = "";
    	String vaultUrl = "https://blah.vault.azure.net/";
    	String secretName = "VMPassword";
    	
    	KeyVaultCredentials credentials = new ClientSecretKeyVaultCredential(applicationId, applicationSecret);
    	
    	KeyVaultClient kvc = new KeyVaultClient(credentials);
    	SecretBundle secret = kvc.getSecret(vaultUrl, secretName);
    	
        System.out.println(secret.value());
    }
}
