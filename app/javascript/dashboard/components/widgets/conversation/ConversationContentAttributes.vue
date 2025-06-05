<script setup>
import { ref, reactive, watch, computed } from 'vue';
import { useStore } from 'vuex';

const props = defineProps({
  conversation: {
    type: Object,
    required: false, // Make it optional since we'll get it from store
  },
});
const emit = defineEmits(['update:contentAttributes']);

const store = useStore();

// Get conversation directly from store using the getter
const conversation = computed(() => {
  return store.getters.getSelectedChat || {};
});

// Dropdown options
const channelOptions = [
  { value: 'chat', label: 'Chat' },
  { value: 'email', label: 'Email' },
  { value: 'sms', label: 'SMS' },
  { value: 'api', label: 'API' },
];
const priorityOptions = [
  { value: 'high', label: 'High' },
  { value: 'medium', label: 'Medium' },
  { value: 'low', label: 'Low' },
];
const categoryOptions = [
  { value: 'technical', label: 'Technical' },
  { value: 'billing', label: 'Billing' },
  { value: 'general', label: 'General' },
  { value: 'complaint', label: 'Complaint' },
];

const fields = {
  conversation_context: [
    { key: 'channel', label: 'Channel', type: 'dropdown', options: channelOptions },
    { key: 'priority', label: 'Priority', type: 'dropdown', options: priorityOptions },
    { key: 'category', label: 'Category', type: 'dropdown', options: categoryOptions },
  ],
  resolution_context: [
    { key: 'topic_category', label: 'Topic Category', type: 'text' },
    { key: 'complexity_level', label: 'Complexity Level', type: 'text' },
  ],
  customer_satisfaction: [
    { key: 'csat_score', label: 'CSAT Score', type: 'text' },
    { key: 'feedback', label: 'Feedback', type: 'text' },
  ],
};

const editMode = ref({
  context: false,
  resolution: false,
  satisfaction: false,
});
const editData = reactive({
  context: {},
  resolution: {},
  satisfaction: {},
});
const saving = ref(false);

const contentAttributes = computed(() => conversation.value?.content_attributes || {});

// Check if we have a valid conversation
const hasValidConversation = computed(() => {
  console.log('=== DEBUGGING CONVERSATION STATE ===');
  console.log('Conversation from store getter:', conversation.value);
  console.log('Conversation keys:', Object.keys(conversation.value || {}));
  console.log('Conversation id:', conversation.value?.id);
  console.log('Conversation display_id:', conversation.value?.display_id);
  
  // Check for both id and display_id as the conversation might use either
  return Boolean(conversation.value?.id || conversation.value?.display_id);
});

function enableEditMode(section) {
  editMode.value[section] = true;
  initializeEditData(section);
}
function cancelEdit(section) {
  editMode.value[section] = false;
  editData[section] = {};
}
function initializeEditData(section) {
  if (section === 'context') {
    editData.context = {
      channel: contentAttributes.value.conversation_context?.channel || '',
      priority: contentAttributes.value.conversation_context?.priority || '',
      category: contentAttributes.value.conversation_context?.category || '',
    };
  } else if (section === 'resolution') {
    editData.resolution = {
      topic_category: contentAttributes.value.resolution_context?.topic_category || '',
      complexity_level: contentAttributes.value.resolution_context?.complexity_level || '',
    };
  } else if (section === 'satisfaction') {
    editData.satisfaction = {
      csat_score: contentAttributes.value.customer_satisfaction?.csat_score || '',
      feedback: contentAttributes.value.customer_satisfaction?.feedback || '',
    };
  }
}
async function saveSection(section) {
  // Check if we have a valid conversation before saving
  if (!conversation.value?.id && !conversation.value?.display_id) {
    console.error('Cannot save: No valid conversation selected');
    return;
  }
  
  saving.value = true;
  try {
    const updated = { ...contentAttributes.value };
    if (section === 'context') {
      updated.conversation_context = { ...updated.conversation_context, ...editData.context };
    } else if (section === 'resolution') {
      updated.resolution_context = { ...updated.resolution_context, ...editData.resolution };
    } else if (section === 'satisfaction') {
      updated.customer_satisfaction = { ...updated.customer_satisfaction, ...editData.satisfaction };
    }
    emit('update:contentAttributes', updated);
    editMode.value[section] = false;
    editData[section] = {};
  } finally {
    saving.value = false;
  }
}
function getDropdownLabel(options, value) {
  const found = options.find(opt => opt.value === value);
  return found ? found.label : '';
}
function getBadgeClass(type, value) {
  if (type === 'priority') {
    if (value === 'high') return 'badge--danger';
    if (value === 'medium') return 'badge--warning';
    if (value === 'low') return 'badge--success';
  }
  return 'badge--secondary';
}
// Dynamic interaction patterns
const messagesCount = computed(() => {
  // Check if we have a valid conversation with an ID (not just an empty object)
  if (!conversation.value?.id && !conversation.value?.display_id) {
    console.log('No valid conversation selected');
    return 0;
  }
  
  console.log('Conversation object:', conversation.value);
  
  // Check if messages exist and is an array
  if (conversation.value?.messages) {
    console.log('Messages array:', conversation.value.messages);
    
    // Debug each message to see what types we have
    conversation.value.messages.forEach((msg, index) => {
      console.log(`Message ${index}:`, {
        id: msg.id,
        content: msg.content?.substring(0, 50) + '...',
        message_type: msg.message_type,
        private: msg.private,
        sender: msg.sender,
        created_at: msg.created_at
      });
    });
    
    if (Array.isArray(conversation.value.messages)) {
      const totalCount = conversation.value.messages.length;
      const visibleMessages = conversation.value.messages.filter(msg => !msg.private);
      console.log(`Total messages: ${totalCount}, Visible (non-private): ${visibleMessages.length}`);
      return totalCount;
    }
  }
  
  // Fallback to content attributes if available
  const fallbackCount = contentAttributes.value.interaction_patterns?.messages_count;
  console.log('Fallback messages count:', fallbackCount);
  return fallbackCount ?? 0;
});
const lastActivityType = computed(() => {
  // Check if we have a valid conversation
  if (!conversation.value?.id && !conversation.value?.display_id) {
    return 'N/A';
  }
  
  if (conversation.value?.messages && Array.isArray(conversation.value.messages) && conversation.value.messages.length > 0) {
    const lastMsg = conversation.value.messages[conversation.value.messages.length - 1];
    
    // Map message types to readable labels
    switch (lastMsg.message_type) {
      case 0:
        return 'Inbound';
      case 1:
        return 'Outbound';
      case 2:
        return 'Activity';
      case 3:
        return 'Template';
      default:
        return `Type ${lastMsg.message_type}`;
    }
  }
  
  const val = contentAttributes.value.interaction_patterns?.last_activity_type;
  if (!val) return 'N/A';
  if (val === 'incoming') return 'Inbound';
  if (val === 'outgoing') return 'Outbound';
  return val.charAt(0).toUpperCase() + val.slice(1);
});
</script>

<template>
  <div class="content-attributes-root">
    <div v-if="!hasValidConversation" class="no-conversation-message">
      <p>Please select a conversation to view content attributes.</p>
    </div>
    <div v-else>
      <!-- Conversation Context -->
      <div class="section-block">
        <div class="section-header">
          <span>Conversation Context</span>
          <button v-if="!editMode.context" class="icon-btn" @click="enableEditMode('context')" title="Edit"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#888" stroke-width="2" d="M16.475 5.408l2.117-2.116a2 2 0 112.829 2.828l-2.116 2.117m-2.83-2.83l-9.193 9.192a2 2 0 00-.497.828l-1.06 3.182a.5.5 0 00.632.632l3.182-1.06a2 2 0 00.828-.497l9.192-9.193m-2.83-2.83l2.83 2.83"/></svg></button>
          <div v-else class="edit-actions">
            <button @click="saveSection('context')" class="icon-btn" :disabled="saving" title="Save"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#22c55e" stroke-width="2" d="M5 13l4 4L19 7"/></svg></button>
            <button @click="cancelEdit('context')" class="icon-btn" title="Cancel"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#ef4444" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>
          </div>
        </div>
        <div v-if="editMode.context" class="edit-form">
          <div class="form-group" v-for="field in fields.conversation_context" :key="field.key">
            <label>{{ field.label }}</label>
            <select v-if="field.type === 'dropdown'" v-model="editData.context[field.key]" class="input-field styled-select">
              <option value="">Select {{ field.label.toLowerCase() }}</option>
              <option v-for="opt in field.options" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
          </div>
        </div>
        <div v-else>
          <div class="attribute-group" v-for="field in fields.conversation_context" :key="field.key">
            <div class="attribute-label">{{ field.label }}</div>
            <div class="attribute-value">
              <span v-if="field.type === 'dropdown' && contentAttributes.conversation_context?.[field.key]" class="badge" :class="getBadgeClass(field.key, contentAttributes.conversation_context[field.key])">
                {{ getDropdownLabel(field.options, contentAttributes.conversation_context[field.key]) }}
              </span>
              <span v-else>{{ contentAttributes.conversation_context?.[field.key] || 'N/A' }}</span>
            </div>
          </div>
        </div>
      </div>
      <hr class="section-divider" />
      <!-- Interaction Patterns (read-only) -->
      <div class="section-block">
        <div class="section-header">
          <span>Interaction Patterns <span class="auto-label">(Auto-updated)</span></span>
        </div>
        <div class="attribute-group">
          <div class="attribute-label">Messages Count</div>
          <div class="attribute-value">{{ messagesCount }}</div>
        </div>
        <div class="attribute-group">
          <div class="attribute-label">Last Activity Type</div>
          <div class="attribute-value">{{ lastActivityType }}</div>
        </div>
      </div>
      <hr class="section-divider" />
      <!-- Resolution Context -->
      <div class="section-block">
        <div class="section-header">
          <span>Resolution Context</span>
          <button v-if="!editMode.resolution" class="icon-btn" @click="enableEditMode('resolution')" title="Edit"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#888" stroke-width="2" d="M16.475 5.408l2.117-2.116a2 2 0 112.829 2.828l-2.116 2.117m-2.83-2.83l-9.193 9.192a2 2 0 00-.497.828l-1.06 3.182a.5.5 0 00.632.632l3.182-1.06a2 2 0 00.828-.497l9.192-9.193m-2.83-2.83l2.83 2.83"/></svg></button>
          <div v-else class="edit-actions">
            <button @click="saveSection('resolution')" class="icon-btn" :disabled="saving" title="Save"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#22c55e" stroke-width="2" d="M5 13l4 4L19 7"/></svg></button>
            <button @click="cancelEdit('resolution')" class="icon-btn" title="Cancel"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#ef4444" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>
          </div>
        </div>
        <div v-if="editMode.resolution" class="edit-form">
          <div class="form-group" v-for="field in fields.resolution_context" :key="field.key">
            <label>{{ field.label }}</label>
            <input class="input-field" type="text" v-model="editData.resolution[field.key]" />
          </div>
        </div>
        <div v-else>
          <div class="attribute-group" v-for="field in fields.resolution_context" :key="field.key">
            <div class="attribute-label">{{ field.label }}</div>
            <div class="attribute-value">{{ contentAttributes.resolution_context?.[field.key] || 'N/A' }}</div>
          </div>
        </div>
      </div>
      <hr class="section-divider" />
      <!-- Customer Satisfaction -->
      <div class="section-block">
        <div class="section-header">
          <span>Customer Satisfaction</span>
          <button v-if="!editMode.satisfaction" class="icon-btn" @click="enableEditMode('satisfaction')" title="Edit"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#888" stroke-width="2" d="M16.475 5.408l2.117-2.116a2 2 0 112.829 2.828l-2.116 2.117m-2.83-2.83l-9.193 9.192a2 2 0 00-.497.828l-1.06 3.182a.5.5 0 00.632.632l3.182-1.06a2 2 0 00.828-.497l9.192-9.193m-2.83-2.83l2.83 2.83"/></svg></button>
          <div v-else class="edit-actions">
            <button @click="saveSection('satisfaction')" class="icon-btn" :disabled="saving" title="Save"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#22c55e" stroke-width="2" d="M5 13l4 4L19 7"/></svg></button>
            <button @click="cancelEdit('satisfaction')" class="icon-btn" title="Cancel"><svg width="16" height="16" fill="none" viewBox="0 0 24 24"><path stroke="#ef4444" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>
          </div>
        </div>
        <div v-if="editMode.satisfaction" class="edit-form">
          <div class="form-group" v-for="field in fields.customer_satisfaction" :key="field.key">
            <label>{{ field.label }}</label>
            <input class="input-field" type="text" v-model="editData.satisfaction[field.key]" />
          </div>
        </div>
        <div v-else>
          <div class="attribute-group" v-for="field in fields.customer_satisfaction" :key="field.key">
            <div class="attribute-label">{{ field.label }}</div>
            <div class="attribute-value">{{ contentAttributes.customer_satisfaction?.[field.key] || 'N/A' }}</div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="saving" class="loading-overlay">
      <div class="loading-spinner"></div>
    </div>
  </div>
</template>

<style scoped>
.content-attributes-root {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1rem;
}
.section-block {
  margin-bottom: 0.5rem;
}
.section-header {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  @apply text-n-slate-12;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.section-divider {
  border: none;
  @apply border-t border-n-weak;
  margin: 0.5rem 0 0.5rem 0;
}
.attribute-group {
  margin-bottom: 12px;
}
.attribute-label {
  font-size: 13px;
  @apply text-n-slate-11;
  font-weight: 500;
  margin-bottom: 2px;
}
.attribute-value {
  font-size: 15px;
  @apply text-n-slate-12;
  word-break: break-word;
}
.badge {
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
  text-transform: capitalize;
}
.badge--success { background: #d1fae5; color: #065f46; }
.badge--warning { background: #fef3c7; color: #92400e; }
.badge--danger { background: #fecaca; color: #991b1b; }
.badge--secondary { background: #f3f4f6; color: #374151; }
.edit-form {
  @apply bg-n-slate-2 border border-n-weak;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
}
.form-group {
  margin-bottom: 16px;
}
.form-group:last-child {
  margin-bottom: 0;
}
.form-group label {
  display: block;
  font-size: 12px;
  @apply text-n-slate-11;
  font-weight: 500;
  margin-bottom: 4px;
}
.input-field {
  width: 100%;
  @apply bg-n-background border border-n-weak text-n-slate-12;
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 14px;
}
.styled-select {
  appearance: none;
  @apply bg-n-background;
  background-image: url('data:image/svg+xml;utf8,<svg fill="%23888" height="16" viewBox="0 0 24 24" width="16" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>');
  background-repeat: no-repeat;
  background-position: right 0.5em center;
  background-size: 1em 1em;
  padding-right: 2em;
}
.icon-btn {
  background: none;
  border: none;
  margin-left: 0.5em;
  cursor: pointer;
  padding: 2px;
  display: inline-flex;
  align-items: center;
}
.auto-label {
  font-size: 10px;
  @apply text-n-slate-10;
  font-weight: 400;
  text-transform: none;
}
.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
}
.loading-spinner {
  width: 24px;
  height: 24px;
  @apply border-2 border-n-weak border-t-n-brand;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
.no-conversation-message {
  text-align: center;
  padding: 2rem;
  @apply text-n-slate-10;
}
.no-conversation-message p {
  margin: 0;
  font-size: 14px;
}
</style>
