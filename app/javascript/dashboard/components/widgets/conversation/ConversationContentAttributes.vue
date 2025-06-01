<script setup>
import { computed } from 'vue';

const props = defineProps({
  contentAttributes: {
    type: Object,
    default: () => ({}),
  },
});

const hasAttributes = computed(() => {
  return props.contentAttributes && Object.keys(props.contentAttributes).length > 0;
});
</script>

<template>
  <div>
    <h4 class="font-semibold mb-2">Content Attributes</h4>
    <div v-if="hasAttributes">
      <ul>
        <li v-for="(value, key) in contentAttributes" :key="key">
          <strong>{{ key }}:</strong> {{ value }}
        </li>
      </ul>
    </div>
    <div v-else>
      <em>No content attributes found.</em>
    </div>
  </div>
</template>

<style scoped>
ul {
  list-style: none;
  padding: 0;
}
li {
  margin-bottom: 0.5em;
}
</style>
