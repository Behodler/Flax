/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { SafeCast, SafeCastInterface } from "../SafeCast";

const _abi = [
  {
    type: "error",
    name: "SafeCastOverflowedIntDowncast",
    inputs: [
      {
        name: "bits",
        type: "uint8",
        internalType: "uint8",
      },
      {
        name: "value",
        type: "int256",
        internalType: "int256",
      },
    ],
  },
  {
    type: "error",
    name: "SafeCastOverflowedIntToUint",
    inputs: [
      {
        name: "value",
        type: "int256",
        internalType: "int256",
      },
    ],
  },
  {
    type: "error",
    name: "SafeCastOverflowedUintDowncast",
    inputs: [
      {
        name: "bits",
        type: "uint8",
        internalType: "uint8",
      },
      {
        name: "value",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
  {
    type: "error",
    name: "SafeCastOverflowedUintToInt",
    inputs: [
      {
        name: "value",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
] as const;

export class SafeCast__factory {
  static readonly abi = _abi;
  static createInterface(): SafeCastInterface {
    return new utils.Interface(_abi) as SafeCastInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): SafeCast {
    return new Contract(address, _abi, signerOrProvider) as SafeCast;
  }
}