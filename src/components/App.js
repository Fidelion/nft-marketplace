import React, { Component, useCallback, useEffect, useState } from "react";
import Web3 from "web3";
import detectEthereumProvider from "@metamask/detect-provider";
import CryptoMonkey from "../abis/CryptoMonkey.json";

export default class App extends Component {
	async componentDidMount() {
		await this.loadWeb3();
		await this.loadAccounts();
	}

	async loadWeb3() {
		const provider = await detectEthereumProvider();

		if (provider) {
			console.log("your browser supports our app");
			window.web3 = new Web3(provider);
		} else {
			console.log("your browser does not support our app");
		}
	}

	async loadAccounts() {
		const web3 = window.web3;
		const accounts = await web3.eth.requestAccounts();
		this.setState({ accounts });

		const networkId = await web3.eth.net.getId();
		const networkData = await CryptoMonkey.networks[networkId];
		if (networkData) {
			const abi = await CryptoMonkey;
			const address = networkData;
			// const abi = CryptoMonkey.abi;
			// const address = networkData.address;
			var contract = new web3.eth.Contract(abi[address]);
			console.log(contract);
		}
	}

	constructor(props) {
		super(props);
		this.state = {
			accounts: "",
		};
	}

	render() {
		return <div>NFT Marketplace</div>;
	}
}
