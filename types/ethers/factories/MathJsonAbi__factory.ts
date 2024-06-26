/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { MathJsonAbi, MathJsonAbiInterface } from "../MathJsonAbi";

const _abi = [
  {
    type: "error",
    name: "MathOverflowedMulDiv",
    inputs: [],
  },
] as const;

export class MathJsonAbi__factory {
  static readonly abi = _abi;
  static createInterface(): MathJsonAbiInterface {
    return new utils.Interface(_abi) as MathJsonAbiInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): MathJsonAbi {
    return new Contract(address, _abi, signerOrProvider) as MathJsonAbi;
  }
}
