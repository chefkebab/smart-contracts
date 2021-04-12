const { time } = require('@openzeppelin/test-helpers');
const BurnChef = artifacts.require('BurnChef');
const MarsToken = artifacts.require('MarsToken');
const MockBEP20 = artifacts.require('libs/MockBEP20');
const Web3 = require('web3');
const { utils } = Web3;

contract('BurnChef', ([alice, minter]) => {
    beforeEach(async () => {
        const block = await web3.eth.getBlock('latest');
        this.currentBlock = block.number;
        this.kebab = await MockBEP20.new('Kebab Token', 'KEBAB', utils.toWei('1000000'), { from: minter });
        this.mars = await MarsToken.new({ from: minter });
        this.chef = await BurnChef.new(this.kebab.address, this.mars.address, this.currentBlock, '1000000000', '100', '1000', { from: minter });
        
    });
    it('burn', async () => {
        await this.kebab.transfer(alice, utils.toWei('10'), { from: minter });
        assert.equal((await this.kebab.balanceOf(alice)).toString(), utils.toWei('10'));
        await this.kebab.approve(this.chef.address, utils.toWei('10'), { from: alice});
        await this.mars.transferOwnership(this.chef.address, { from: minter });
        await this.chef.burn(utils.toWei('1'), { from: alice });
        assert.equal((await this.kebab.balanceOf(alice)).toString(), utils.toWei('9'));
        assert.equal((await this.mars.balanceOf(alice)).toString(), utils.toWei('1'));
        await time.advanceBlockTo(this.currentBlock + 100);
        await this.chef.burn(utils.toWei('1'), { from: alice });
        assert.equal((await this.kebab.balanceOf(alice)).toString(), utils.toWei('8'));
        assert.equal((await this.mars.balanceOf(alice)).toString(), '1999000000000000000');
        await time.advanceBlockTo(this.currentBlock + 200);
        await this.chef.burn(utils.toWei('1'), { from: alice });
        assert.equal((await this.kebab.balanceOf(alice)).toString(), utils.toWei('7'));
        assert.equal((await this.mars.balanceOf(alice)).toString(), '2997001000000000000');
    });
});
