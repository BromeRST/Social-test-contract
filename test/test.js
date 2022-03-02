const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("deploying LOTRToken", function() {
    let LOTRToken;
    let signer;
    let Social;
    let signer2;
    const prov = ethers.provider;
    before("deploy contracts", async function() {
        const SocialContract = await ethers.getContractFactory("Social");
        Social = await SocialContract.deploy()
        const LOTRTokenContract = await ethers.getContractFactory("LOTRToken");
        LOTRToken = await LOTRTokenContract.deploy(Social.address);
        [signer, signer2] = await ethers.getSigners();
    });
    it("signer's balance should be 2000 LOTR", async function() {
        const socialBalance = await prov.getBalance(Social.address);
        /* console.log("here", ethers.utils.formatUnits(socialBalance)) */
        console.log("social address", Social.address);
        const tx = await LOTRToken.mint({value: ethers.utils.parseEther("0.001")});
        await tx.wait();

        assert.equal((await LOTRToken.balanceOf(signer.address)).toString(), ethers.utils.parseEther("2000").toString());
    });
    it("should transfer 1000 of amount from signer1 to signer2", async function () {
        const transf = await LOTRToken.transfer(signer2.address, ethers.utils.parseEther("1000"));
        await transf.wait();

        assert.equal((await LOTRToken.balanceOf(signer2.address)).toString(), ethers.utils.parseEther("1000").toString());
    });
    it("should send the value of txn to Social contract address = 0,001", async function () {
        const socialBalance = await prov.getBalance(Social.address);
        assert.equal(ethers.utils.formatUnits(socialBalance), 0.001);
    });
    it("should post something", async function() {
        await Social.connect(signer2.connect(prov)).post("Hello!", "");
    });
});