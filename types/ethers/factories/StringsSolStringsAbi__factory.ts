/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  StringsSolStringsAbi,
  StringsSolStringsAbiInterface,
} from "../StringsSolStringsAbi";

const _abi = [
  {
    type: "error",
    name: "StringsInsufficientHexLength",
    inputs: [
      {
        name: "value",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "length",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
] as const;

export class StringsSolStringsAbi__factory {
  static readonly abi = _abi;
  static createInterface(): StringsSolStringsAbiInterface {
    return new utils.Interface(_abi) as StringsSolStringsAbiInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): StringsSolStringsAbi {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as StringsSolStringsAbi;
  }
}
