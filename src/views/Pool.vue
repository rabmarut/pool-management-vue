<template>
  <div class="px-0 px-md-5 pt-4">
    <div v-if="loading" class="text-center">
      <UiLoading class="big" />
    </div>
    <div
      v-else-if="!pool"
      class="text-white text-center mt-8"
      style="font-size: 24px;"
    >
      Pool not found
    </div>
    <div v-else>
      <MessageWarning
        v-if="customTokenWarning"
        :text="customTokenWarning"
        class="mb-4"
      />
      <div class="d-flex flex-items-center flex-auto mb-4 px-4 px-md-0">
        <h3 class="flex-auto d-flex flex-items-center">
          <div>Pool {{ _shorten(pool.id) }}</div>
          <a :href="_etherscanLink(pool.id)" target="_blank" class="text-white">
            <Icon name="external-link" size="16" class="ml-1 mr-2" />
          </a>
          <UiLabel v-if="!pool.finalized" v-text="'Private'" />
        </h3>
        <div class="d-flex">
          <UiButton
            class="button-primary ml-2"
            @click="openAddLiquidityModal"
            v-if="enableAddLiquidity"
          >
            Add Liquidity
          </UiButton>
          <UiButton
            v-if="hasShares"
            class="ml-2"
            @click="openRemoveLiquidityModal"
          >
            Remove Liquidity
          </UiButton>
        </div>
      </div>
      <PoolBoxes :pool="pool" />
      <Tabs :pool="pool" />
      <router-view :key="$route.path" :pool="pool" />
    </div>
    <ModalAddLiquidity
      v-if="pool"
      :pool="pool"
      :open="modalAddLiquidityOpen"
      @close="modalAddLiquidityOpen = false"
    />
    <ModalRemoveLiquidity
      v-if="pool"
      :pool="pool"
      :open="modalRemoveLiquidityOpen"
      @close="modalRemoveLiquidityOpen = false"
    />
    <ModalCustomToken
      v-if="hasCustomToken"
      :open="modalCustomTokenOpen"
      @close="modalCustomTokenOpen = false"
    />
  </div>
</template>

<script>
import { mapActions } from 'vuex';

export default {
  data() {
    return {
      id: this.$route.params.id,
      pool: {},
      loading: false,
      modalAddLiquidityOpen: false,
      modalRemoveLiquidityOpen: false,
      modalCustomTokenOpen: true
    };
  },
  computed: {
    customTokenWarning() {
      const warnings = this.config.warnings;
      for (const token in warnings) {
        if (this.pool.tokensList.includes(token)) {
          return warnings[token];
        }
      }
      return undefined;
    },
    hasCustomToken() {
      if (!this.pool.tokens) {
        return false;
      }
      for (const token of this.pool.tokens) {
        const tokenMetadata = this.web3.tokenMetadata[token.checksum];
        if (!tokenMetadata || !tokenMetadata.whitelisted) {
          return true;
        }
      }
      return false;
    },
    hasShares() {
      return Object.keys(this.subgraph.poolShares).includes(this.id);
    },
    enableAddLiquidity() {
      return this.pool.finalized && this.pool.totalShares !== '0';
    }
  },
  methods: {
    ...mapActions([
      'getPool',
      'getBalances',
      'getAllowances',
      'loadTokenMetadata',
      'loadPricesByAddress'
    ]),
    openAddLiquidityModal() {
      if (!this.hasProxy) {
        return this.$router.push({ name: 'setup' });
      }
      this.modalAddLiquidityOpen = true;
    },
    openRemoveLiquidityModal() {
      this.modalRemoveLiquidityOpen = true;
    }
  },
  async created() {
    if (Object.keys(this.pool).length === 0) {
      this.loading = true;
      this.pool = await this.getPool(this.id);
      if (!this.pool) {
        this.loading = false;
        return;
      }
      const unknownTokens = this.pool.tokensList.filter(
        tokenAddress => !this.web3.tokenMetadata[tokenAddress]
      );
      if (unknownTokens.length > 0) {
        await this.loadTokenMetadata(unknownTokens);
        await this.loadPricesByAddress(unknownTokens);
      }
      if (this.web3.account) {
        await Promise.all([
          this.getBalances(this.pool.tokensList),
          this.getAllowances({
            tokens: this.pool.tokensList,
            spender: this.web3.dsProxyAddress
          })
        ]);
      }
      this.loading = false;
    }
  }
};
</script>
