/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IERC165SolIERC165Abi,
  IERC165SolIERC165AbiInterface,
} from "../IERC165SolIERC165Abi";

const _abi = [
  {
    type: "function",
    name: "supportsInterface",
    inputs: [
      {
        name: "interfaceID",
        type: "bytes4",
        internalType: "bytes4",
      },
    ],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
] as const;

export class IERC165SolIERC165Abi__factory {
  static readonly abi = _abi;
  static createInterface(): IERC165SolIERC165AbiInterface {
    return new utils.Interface(_abi) as IERC165SolIERC165AbiInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IERC165SolIERC165Abi {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as IERC165SolIERC165Abi;
  }
}
