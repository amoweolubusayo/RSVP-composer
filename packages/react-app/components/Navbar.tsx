import { useState, useEffect } from "react";
import Link from "next/link";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, useDisconnect } from "wagmi";
import Navmenu from "./Navmenu";

export default function Navbar() {
  const { address } = useAccount();
  const { disconnect } = useDisconnect();

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    mounted && (
      <header className="bg-white border-b-2 border-gray-100">
        <nav
          className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
          aria-label="Top"
        >
          <div className="w-full py-6 flex flex-wrap items-center justify-between border-b border-yellow-500 lg:border-none">
            <div className="flex items-center"></div>
            <div className="ml-10 space-x-4 flex items-center">
              {address ? (
                <Navmenu address={address} disconnect={() => disconnect()} />
              ) : (
                <ConnectButton />
              )}
            </div>
          </div>
        </nav>
      </header>
    )
  );
}
