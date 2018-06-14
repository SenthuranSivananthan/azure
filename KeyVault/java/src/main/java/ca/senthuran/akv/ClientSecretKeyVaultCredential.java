package ca.senthuran.akv;

import java.net.MalformedURLException;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import com.microsoft.aad.adal4j.AuthenticationContext;
import com.microsoft.aad.adal4j.AuthenticationResult;
import com.microsoft.aad.adal4j.ClientCredential;
import com.microsoft.azure.keyvault.authentication.KeyVaultCredentials;

public class ClientSecretKeyVaultCredential extends KeyVaultCredentials {

	private String applicationId;
	private String applicationSecret;

	public ClientSecretKeyVaultCredential(String applicationId, String applicationSecret) {
		this.setApplicationId(applicationId);
		this.setApplicationSecret(applicationSecret);
	}

	public String getApplicationId() {
		return applicationId;
	}

	private void setApplicationId(String applicationId) {
		this.applicationId = applicationId;
	}

	public String getApplicationSecret() {
		return applicationSecret;
	}

	private void setApplicationSecret(String applicationSecret) {
		this.applicationSecret = applicationSecret;
	}

	@Override
	public String doAuthenticate(String authorization, String resource, String scope) {
		AuthenticationResult res = null;

		try {
			res = GetAccessToken(authorization, resource, this.applicationId, this.applicationSecret);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ExecutionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return res.getAccessToken();
	}

	private AuthenticationResult GetAccessToken(String authorization, String resource, String clientID,
			String clientKey) throws InterruptedException, ExecutionException {
		AuthenticationContext ctx = null;
		ExecutorService service = Executors.newFixedThreadPool(1);
		try {
			ctx = new AuthenticationContext(authorization, false, service);
		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Future<AuthenticationResult> resp = ctx.acquireToken(resource, new ClientCredential(clientID, clientKey), null);
		AuthenticationResult res = resp.get();
		
		return res;
	}
}
