import React, { useEffect, useState } from "react";
import { Actor } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
// import { corrupted_pigs_backend } from "declarations/corrupted_pigs_backend";

const WalletConnect = () => {

  const [authClient, setAuthClient] = useState(null);
  const [principalId, setPrincipalId] = useState(null);

  useEffect(() => {
    async function init() {
      const client = await AuthClient.create();
      setAuthClient(client);
    }
    init();
  }, []);

  const handleSuccess = async () => {
    const identity = authClient.getIdentity();
    const principal = await identity.getPrincipal().toString();
    setPrincipalId(principal);

    // Actor.agentOf(corrupted_pigs_backend).replaceIdentity(identity);
  }

  const handleLogin = async () => {
    if (!authClient) throw new Error("AuthClient not initialized");

    const APP_NAME = "homevestorsDAO";
    const APP_LOGO = "https://logo.clearbit.com/clearbit.com" // "/logo-white.svg";
    const CONFIG_QUERY = `?applicationName=${APP_NAME}&applicationLogo=${APP_LOGO}`;

    const identityProvider = `https://nfid.one/authenticate${CONFIG_QUERY}`;

    authClient.login({
      identityProvider,
      onSuccess: handleSuccess,
      windowOpenerFeatures: `
        left=${window.screen.width / 2 - 525 / 2},
        top=${window.screen.height / 2 - 705 / 2},
        toolbar=0,location=0,menubar=0,width=525,height=705
      `,
    });
  };

  return (
    <div>
      {!principalId ? (
        <button onClick={handleLogin}>Login Wallet</button>
      ) : (
        <p>Your PrincipalId: {principalId}</p>
      )}
    </div>
  );
};

export default WalletConnect;
