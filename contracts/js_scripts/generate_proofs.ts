import { Barretenberg, Fr, UltraHonkBackend } from "@aztec/bb.js";
import { ethers } from "ethers";
import { Noir } from "@noir-lang/noir_js";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";


const circuitPath = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../../circuits/target/circuits.json"
);
const circuit = JSON.parse(fs.readFileSync(circuitPath, "utf8"));


function hexToArray(hex: string): number[] {
  const cleanHex = hex.startsWith("0x") ? hex.slice(2) : hex;
  if (cleanHex.length !== 64) {
    throw new Error("Invalid hex string length: must be 32 bytes (64 hex chars)");
  }
  const bytes = new Array(32);
  for (let i = 0; i < 32; i++) {
    bytes[i] = parseInt(cleanHex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}


export default async function generateProof(){

    const inputsArray = process.argv.slice(2);

    try{
        const noir = new Noir(circuit)

        const bb = new UltraHonkBackend(circuit.bytecode, {threads:1})

        const inputs ={
            guess_hash: hexToArray(inputsArray[0]),
            answer_hash: hexToArray(inputsArray[1]),
        }

        const {witness} = await noir.execute(inputs)
       const  original_log = console.log 
        console.log = () => {}
        const {proof, publicInputs} = await bb.generateProof(witness, {keccak:true})
        console.log = original_log
       const encodedProof = ethers.utils.defaultAbiCoder.encode(
                ["bytes","bytes32[]"],
                [proof, publicInputs]
       );

        return encodedProof

    }catch(error){
        console.log(error)
         throw error 
        }

}


(async () =>{
    generateProof()
    .then((proof)=>{
        process.stdout.write(proof)
        process.exit(0)
    }).catch((e)=>console.log(e))
}
)();