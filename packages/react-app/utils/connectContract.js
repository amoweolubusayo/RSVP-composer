import abiJSON from "./Web3RSVP.json";
import { ethers } from "ethers";

function connectContract() {
  const contractAddress = "0xc85CA226772cA949801EfCA6B9d153fB4a833aF7";
  const contractABI = abiJSON.abi;
  let rsvpContract;
  try {
    const { ethereum } = window;

    if (ethereum.chainId === "0xaef3") {
      //checking for eth object in the window, see if they have wallet connected to Alfajeros network
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      console.log("contractABI", contractABI);
      rsvpContract = new ethers.Contract(contractAddress, contractABI, signer); // instantiating new connection to the contract
    } else {
      throw new Error("Please connect to the Polygon Alfajeros network.");
    }
  } catch (error) {
    console.log("ERROR:", error);
  }
  return rsvpContract;
}

export default connectContract;
