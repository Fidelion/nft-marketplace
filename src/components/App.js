import React, { Component } from "react";
import Web3 from "web3";
import detectEthereumProvider from "@metamask/detect-provider";
import CryptoMonkey from "../abis/CryptoMonkey.json";
import {
	MDBCard,
	MDBCardBody,
	MDBCardTitle,
	MDBCardText,
	MDBCardImage,
	MDBBtn,
} from "mdb-react-ui-kit";
import "./App.css";

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
		const accounts = await web3.eth.getAccounts();
		this.setState({ account: accounts[0] });

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
			<div>
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

				<div className="container-fluid mt-1">
					<div className="row">
						<main role="main" className="col-lg-12 d-flex text-center">
							<div
								className="content mr-auto ml-auto"
								style={{ margin: "50px" }}
							>
								<h1>CryptoMonkeyz - NFT Marketplace</h1>
								<form
									onSubmit={(event) => {
										event.preventDefault();
										const cryptoMonkey = this.cryptoMonkey.value;
										this.mint(cryptoMonkey);
									}}
								>
									<input
										type="text"
										placeholder="Add A file location"
										className="form-control mb-1"
										ref={(input) => (this.cryptoMonkey = input)}
									/>
									<input
										style={{ margin: "6px" }}
										type="submit"
										className="btn btn-primary btn-black"
										value="MINT"
									/>
								</form>
							</div>
						</main>
					</div>

					<hr></hr>
					<div className="row textCenter">
						{this.state.cryptoMonkeyz.map((cryptoMonkey, key) => {
							return (
								<div>
									<div>
										<MDBCard
											className="token img"
											style={{ maxWidth: "22rem" }}
										>
											<MDBCardImage
												src={cryptoMonkey}
												position="top"
												height="250rem"
												style={{ marginRight: "4px" }}
											/>
											<MDBCardBody>
												<MDBCardTitle> CryptoMonkeyz </MDBCardTitle>
												<MDBCardText>
													{" "}
													The CryptoMonkeyz are 20 uniquely generated CMonkeyz
													from the cyberpunk cloud galaxy Mystopia! There is
													only one of each bird and each bird can be owned by a
													single person on the Ethereum blockchain.{" "}
												</MDBCardText>
												<MDBBtn href={cryptoMonkey}>Download</MDBBtn>
											</MDBCardBody>
										</MDBCard>
									</div>
								</div>
							);
						})}
					</div>
				</div>
			</div>
		);
	}
}
