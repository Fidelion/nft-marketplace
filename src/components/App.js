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
		this.setState({ account: accounts });

		const networkId = await web3.eth.net.getId();
		const networkData = await CryptoMonkey.networks[networkId];
		if (networkData) {
			const abi = CryptoMonkey.abi;
			const address = networkData.address;
			const contract = new web3.eth.Contract(abi, address);
			this.setState({ contract });
			console.log(this.state.contract);
			const totalSupply = await contract.methods.totalSupply().call();
			this.setState({ totalSupply });

			for (let i = 1; i <= totalSupply; i++) {
				const CryptoMonkey = await contract.methods.cryptoMonkeyz(i - 1).call();
				this.setState({
					cryptoMonkeyz: [...this.state.cryptoMonkeyz, CryptoMonkey],
				});
			}

			console.log(this.state.cryptoMonkeyz);
		} else {
			window.alert("Smart contract not deployed");
		}
	}

	mint = (cryptoMonkey) => {
		this.state.contract.methods
			.mint(cryptoMonkey)
			.send({ from: this.state.account })
			.once("minted", () => {
				this.setState({
					cryptoMonkeyz: [...this.state.cryptoMonkeyz, cryptoMonkey],
				});
			});
	};

	constructor(props) {
		super(props);
		this.state = {
			account: "",
			contract: null,
			totalSupply: 0,
			cryptoMonkeyz: [],
		};
	}

	render() {
		return (
			<nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
				<div className="navbar-brand col-sm-3 col-md-3 mr-0">
					CryptoMonkeyz NFT Platform
				</div>
				<ul className="navbar-nav px-3">
					<li className="nav-item text-nowrap d-none d-sm-non d-sm-block">
						<small className="text-white">{this.state.account}</small>
					</li>
				</ul>
			</nav>
		);
	}
}
