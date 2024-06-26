/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
} from "./common";

export interface IssuerInterface extends utils.Interface {
  functions: {
    "allowanceIncreasers(address)": FunctionFragment;
    "burnBurnable(address)": FunctionFragment;
    "couponContract()": FunctionFragment;
    "increaseAllowance(uint256)": FunctionFragment;
    "issue(address,uint256)": FunctionFragment;
    "mintAllowance()": FunctionFragment;
    "owner()": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "setCouponContract(address)": FunctionFragment;
    "setTokenInfo(address,bool,bool,uint256)": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
    "whitelist(address)": FunctionFragment;
    "whitelistAllowanceIncreasers(address,bool)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "allowanceIncreasers"
      | "burnBurnable"
      | "couponContract"
      | "increaseAllowance"
      | "issue"
      | "mintAllowance"
      | "owner"
      | "renounceOwnership"
      | "setCouponContract"
      | "setTokenInfo"
      | "transferOwnership"
      | "whitelist"
      | "whitelistAllowanceIncreasers"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "allowanceIncreasers",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "burnBurnable",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "couponContract",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "increaseAllowance",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "issue",
    values: [string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "mintAllowance",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "renounceOwnership",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "setCouponContract",
    values: [string]
  ): string;
  encodeFunctionData(
    functionFragment: "setTokenInfo",
    values: [string, boolean, boolean, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "transferOwnership",
    values: [string]
  ): string;
  encodeFunctionData(functionFragment: "whitelist", values: [string]): string;
  encodeFunctionData(
    functionFragment: "whitelistAllowanceIncreasers",
    values: [string, boolean]
  ): string;

  decodeFunctionResult(
    functionFragment: "allowanceIncreasers",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "burnBurnable",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "couponContract",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "increaseAllowance",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "issue", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "mintAllowance",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "renounceOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setCouponContract",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "setTokenInfo",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "whitelist", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "whitelistAllowanceIncreasers",
    data: BytesLike
  ): Result;

  events: {
    "CouponsIssued(address,address,uint256,uint256)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
    "TokenWhitelisted(address,bool,bool,uint256)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "CouponsIssued"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "TokenWhitelisted"): EventFragment;
}

export interface CouponsIssuedEventObject {
  user: string;
  token: string;
  amount: BigNumber;
  coupons: BigNumber;
}
export type CouponsIssuedEvent = TypedEvent<
  [string, string, BigNumber, BigNumber],
  CouponsIssuedEventObject
>;

export type CouponsIssuedEventFilter = TypedEventFilter<CouponsIssuedEvent>;

export interface OwnershipTransferredEventObject {
  previousOwner: string;
  newOwner: string;
}
export type OwnershipTransferredEvent = TypedEvent<
  [string, string],
  OwnershipTransferredEventObject
>;

export type OwnershipTransferredEventFilter =
  TypedEventFilter<OwnershipTransferredEvent>;

export interface TokenWhitelistedEventObject {
  token: string;
  enabled: boolean;
  burnable: boolean;
  teraCouponPerToken: BigNumber;
}
export type TokenWhitelistedEvent = TypedEvent<
  [string, boolean, boolean, BigNumber],
  TokenWhitelistedEventObject
>;

export type TokenWhitelistedEventFilter =
  TypedEventFilter<TokenWhitelistedEvent>;

export interface Issuer extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IssuerInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    allowanceIncreasers(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    burnBurnable(
      tokenAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    couponContract(overrides?: CallOverrides): Promise<[string]>;

    increaseAllowance(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    issue(
      inputToken: string,
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    mintAllowance(overrides?: CallOverrides): Promise<[BigNumber]>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setCouponContract(
      newCouponAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    setTokenInfo(
      token: string,
      enabled: boolean,
      burnable: boolean,
      teraCouponPerToken: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;

    whitelist(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<
      [boolean, boolean, BigNumber] & {
        enabled: boolean;
        burnable: boolean;
        teraCouponPerToken: BigNumber;
      }
    >;

    whitelistAllowanceIncreasers(
      increaser: string,
      _whitelist: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<ContractTransaction>;
  };

  allowanceIncreasers(
    arg0: string,
    overrides?: CallOverrides
  ): Promise<boolean>;

  burnBurnable(
    tokenAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  couponContract(overrides?: CallOverrides): Promise<string>;

  increaseAllowance(
    amount: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  issue(
    inputToken: string,
    amount: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  mintAllowance(overrides?: CallOverrides): Promise<BigNumber>;

  owner(overrides?: CallOverrides): Promise<string>;

  renounceOwnership(
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setCouponContract(
    newCouponAddress: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  setTokenInfo(
    token: string,
    enabled: boolean,
    burnable: boolean,
    teraCouponPerToken: BigNumberish,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  transferOwnership(
    newOwner: string,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  whitelist(
    arg0: string,
    overrides?: CallOverrides
  ): Promise<
    [boolean, boolean, BigNumber] & {
      enabled: boolean;
      burnable: boolean;
      teraCouponPerToken: BigNumber;
    }
  >;

  whitelistAllowanceIncreasers(
    increaser: string,
    _whitelist: boolean,
    overrides?: Overrides & { from?: string }
  ): Promise<ContractTransaction>;

  callStatic: {
    allowanceIncreasers(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<boolean>;

    burnBurnable(
      tokenAddress: string,
      overrides?: CallOverrides
    ): Promise<void>;

    couponContract(overrides?: CallOverrides): Promise<string>;

    increaseAllowance(
      amount: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    issue(
      inputToken: string,
      amount: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    mintAllowance(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<string>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    setCouponContract(
      newCouponAddress: string,
      overrides?: CallOverrides
    ): Promise<void>;

    setTokenInfo(
      token: string,
      enabled: boolean,
      burnable: boolean,
      teraCouponPerToken: BigNumberish,
      overrides?: CallOverrides
    ): Promise<void>;

    transferOwnership(
      newOwner: string,
      overrides?: CallOverrides
    ): Promise<void>;

    whitelist(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<
      [boolean, boolean, BigNumber] & {
        enabled: boolean;
        burnable: boolean;
        teraCouponPerToken: BigNumber;
      }
    >;

    whitelistAllowanceIncreasers(
      increaser: string,
      _whitelist: boolean,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "CouponsIssued(address,address,uint256,uint256)"(
      user?: string | null,
      token?: string | null,
      amount?: null,
      coupons?: null
    ): CouponsIssuedEventFilter;
    CouponsIssued(
      user?: string | null,
      token?: string | null,
      amount?: null,
      coupons?: null
    ): CouponsIssuedEventFilter;

    "OwnershipTransferred(address,address)"(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;
    OwnershipTransferred(
      previousOwner?: string | null,
      newOwner?: string | null
    ): OwnershipTransferredEventFilter;

    "TokenWhitelisted(address,bool,bool,uint256)"(
      token?: null,
      enabled?: null,
      burnable?: null,
      teraCouponPerToken?: null
    ): TokenWhitelistedEventFilter;
    TokenWhitelisted(
      token?: null,
      enabled?: null,
      burnable?: null,
      teraCouponPerToken?: null
    ): TokenWhitelistedEventFilter;
  };

  estimateGas: {
    allowanceIncreasers(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    burnBurnable(
      tokenAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    couponContract(overrides?: CallOverrides): Promise<BigNumber>;

    increaseAllowance(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    issue(
      inputToken: string,
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    mintAllowance(overrides?: CallOverrides): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setCouponContract(
      newCouponAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    setTokenInfo(
      token: string,
      enabled: boolean,
      burnable: boolean,
      teraCouponPerToken: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;

    whitelist(arg0: string, overrides?: CallOverrides): Promise<BigNumber>;

    whitelistAllowanceIncreasers(
      increaser: string,
      _whitelist: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    allowanceIncreasers(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    burnBurnable(
      tokenAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    couponContract(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    increaseAllowance(
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    issue(
      inputToken: string,
      amount: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    mintAllowance(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setCouponContract(
      newCouponAddress: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    setTokenInfo(
      token: string,
      enabled: boolean,
      burnable: boolean,
      teraCouponPerToken: BigNumberish,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: string,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;

    whitelist(
      arg0: string,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    whitelistAllowanceIncreasers(
      increaser: string,
      _whitelist: boolean,
      overrides?: Overrides & { from?: string }
    ): Promise<PopulatedTransaction>;
  };
}
