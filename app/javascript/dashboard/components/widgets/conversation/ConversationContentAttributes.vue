<template>
  <div class="content-attributes-inner">
    <!-- Conversation Context Section -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">Conversation Context</div>
        <button 
          v-if="!editMode.context" 
          @click="enableEditMode('context')"
          class="edit-button"
          title="Edit conversation context"
        >
          <fluent-icon icon="edit" size="16" />
        </button>
        <div v-else class="edit-actions">
          <button @click="saveSection('context')" class="save-button" :disabled="saving">
            <fluent-icon icon="checkmark" size="16" />
          </button>
          <button @click="cancelEdit('context')" class="cancel-button">
            <fluent-icon icon="dismiss" size="16" />
          </button>
        </div>
      </div>

      <!-- Edit Mode for Context -->
      <div v-if="editMode.context" class="edit-form">
        <div class="form-group">
          <label>Channel</label>
          <select v-model="editData.context.channel" class="form-input">
            <option value="">Select channel</option>
            <option value="chat">Chat</option>
            <option value="email">Email</option>
            <option value="phone">Phone</option>
            <option value="social">Social</option>
            <option value="api">API</option>
          </select>
        </div>
        <div class="form-group">
          <label>Source</label>
          <select v-model="editData.context.source" class="form-input">
            <option value="">Select source</option>
            <option value="website">Website</option>
            <option value="mobile_app">Mobile App</option>
            <option value="social_media">Social Media</option>
            <option value="email">Email</option>
            <option value="phone">Phone</option>
          </select>
        </div>
        <div class="form-group">
          <label>Priority</label>
          <select v-model="editData.context.priority" class="form-input">
            <option value="">Select priority</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>
        <div class="form-group">
          <label>Category</label>
          <select v-model="editData.context.category" class="form-input">
            <option value="">Select category</option>
            <option value="support">Support</option>
            <option value="sales">Sales</option>
            <option value="billing">Billing</option>
            <option value="technical">Technical</option>
            <option value="general">General</option>
          </select>
        </div>
        <div class="form-group">
          <label>Tags (comma-separated)</label>
          <input 
            v-model="editData.context.tagsString" 
            type="text" 
            class="form-input"
            placeholder="urgent, billing, payment"
          />
        </div>
      </div>

      <!-- Display Mode for Context -->
      <div v-else>
        <div class="attribute-group">
          <div class="attribute-label">Channel</div>
          <div class="attribute-value">{{ conversationContext?.channel || 'N/A' }}</div>
        </div>
        <div class="attribute-group">
          <div class="attribute-label">Source</div>
          <div class="attribute-value">{{ conversationContext?.source || 'N/A' }}</div>
        </div>
        <div class="attribute-group">
          <div class="attribute-label">Priority</div>
          <div class="attribute-value">
            <span v-if="conversationContext?.priority" class="badge" :class="getPriorityClass(conversationContext.priority)">
              {{ conversationContext.priority }}
            </span>
            <span v-else>N/A</span>
          </div>
        </div>
        <div class="attribute-group">
          <div class="attribute-label">Category</div>
          <div class="attribute-value">{{ conversationContext?.category || 'N/A' }}</div>
        </div>
        <div class="attribute-group" v-if="conversationContext?.tags && conversationContext.tags.length">
          <div class="attribute-label">Tags</div>
          <div class="attribute-value">
            <span v-for="tag in conversationContext.tags" :key="tag" class="tag">{{ tag }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Interaction Patterns Section (Read-only, auto-updated) -->
    <div v-if="interactionPatterns" class="section">
      <div class="section-header">
        <div class="section-title">Interaction Patterns <span class="auto-label">(Auto-updated)</span></div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Messages</div>
        <div class="attribute-value">{{ interactionPatterns.messages_count || interactionPatterns.message_count || 'N/A' }}</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Response Time</div>
        <div class="attribute-value">{{ getResponseTime() }}</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Last Activity</div>
        <div class="attribute-value">{{ interactionPatterns.last_activity_type || 'N/A' }}</div>
      </div>
      <div class="attribute-group" v-if="interactionPatterns.customer_sentiment">
        <div class="attribute-label">Sentiment</div>
        <div class="attribute-value">
          <span class="badge" :class="getSentimentClass(interactionPatterns.customer_sentiment)">
            {{ interactionPatterns.customer_sentiment }}
          </span>
        </div>
      </div>
      <div class="attribute-group" v-if="interactionPatterns.complexity_score">
        <div class="attribute-label">Complexity</div>
        <div class="attribute-value">{{ interactionPatterns.complexity_score }}/10</div>
      </div>
    </div>

    <!-- Resolution Context Section -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">Resolution Context</div>
        <button 
          v-if="!editMode.resolution" 
          @click="enableEditMode('resolution')"
          class="edit-button"
          title="Edit resolution context"
        >
          <fluent-icon icon="edit" size="16" />
        </button>
        <div v-else class="edit-actions">
          <button @click="saveSection('resolution')" class="save-button" :disabled="saving">
            <fluent-icon icon="checkmark" size="16" />
          </button>
          <button @click="cancelEdit('resolution')" class="cancel-button">
            <fluent-icon icon="dismiss" size="16" />
          </button>
        </div>
      </div>

      <!-- Edit Mode for Resolution -->
      <div v-if="editMode.resolution" class="edit-form">
        <div class="form-group">
          <label>Resolution Type</label>
          <select v-model="editData.resolution.resolution_type" class="form-input">
            <option value="">Select type</option>
            <option value="solved">Solved</option>
            <option value="escalated">Escalated</option>
            <option value="transferred">Transferred</option>
            <option value="closed">Closed</option>
          </select>
        </div>
        <div class="form-group">
          <label>Topic Category</label>
          <select v-model="editData.resolution.topic_category" class="form-input">
            <option value="">Select category</option>
            <option value="billing">Billing</option>
            <option value="technical">Technical</option>
            <option value="general">General</option>
            <option value="complaint">Complaint</option>
            <option value="feature_request">Feature Request</option>
          </select>
        </div>
        <div class="form-group">
          <label>Complexity Level</label>
          <select v-model="editData.resolution.complexity_level" class="form-input">
            <option value="">Select complexity</option>
            <option value="simple">Simple</option>
            <option value="moderate">Moderate</option>
            <option value="complex">Complex</option>
          </select>
        </div>
        <div class="form-group">
          <label>Knowledge Base Used</label>
          <select v-model="editData.resolution.knowledge_base_used" class="form-input">
            <option value="">Select option</option>
            <option :value="true">Yes</option>
            <option :value="false">No</option>
          </select>
        </div>
        <div class="form-group">
          <label>Follow-up Required</label>
          <select v-model="editData.resolution.follow_up_required" class="form-input">
            <option value="">Select option</option>
            <option :value="true">Yes</option>
            <option :value="false">No</option>
          </select>
        </div>
      </div>

      <!-- Display Mode for Resolution -->
      <div v-else>
        <div class="attribute-group" v-if="resolutionContext?.resolution_type">
          <div class="attribute-label">Resolution Type</div>
          <div class="attribute-value">
            <span class="badge" :class="getResolutionClass(resolutionContext.resolution_type)">
              {{ resolutionContext.resolution_type }}
            </span>
          </div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.topic_category">
          <div class="attribute-label">Topic Category</div>
          <div class="attribute-value">{{ resolutionContext.topic_category }}</div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.complexity_level">
          <div class="attribute-label">Complexity Level</div>
          <div class="attribute-value">{{ resolutionContext.complexity_level }}</div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.resolution_time">
          <div class="attribute-label">Resolution Time</div>
          <div class="attribute-value">{{ formatDuration(resolutionContext.resolution_time) }}</div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.first_response_time">
          <div class="attribute-label">First Response</div>
          <div class="attribute-value">{{ formatDuration(resolutionContext.first_response_time) }}</div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.knowledge_base_used !== undefined">
          <div class="attribute-label">Knowledge Base Used</div>
          <div class="attribute-value">{{ resolutionContext.knowledge_base_used ? 'Yes' : 'No' }}</div>
        </div>
        <div class="attribute-group" v-if="resolutionContext?.follow_up_required !== undefined">
          <div class="attribute-label">Follow-up Required</div>
          <div class="attribute-value">{{ resolutionContext.follow_up_required ? 'Yes' : 'No' }}</div>
        </div>
        <div v-if="!resolutionContext || Object.keys(resolutionContext).length === 0" class="no-data">
          <div class="attribute-value">No resolution context set</div>
        </div>
      </div>
    </div>

    <!-- Customer Satisfaction Section -->
    <div class="section">
      <div class="section-header">
        <div class="section-title">Customer Satisfaction</div>
        <button 
          v-if="!editMode.satisfaction" 
          @click="enableEditMode('satisfaction')"
          class="edit-button"
          title="Edit customer satisfaction"
        >
          <fluent-icon icon="edit" size="16" />
        </button>
        <div v-else class="edit-actions">
          <button @click="saveSection('satisfaction')" class="save-button" :disabled="saving">
            <fluent-icon icon="checkmark" size="16" />
          </button>
          <button @click="cancelEdit('satisfaction')" class="cancel-button">
            <fluent-icon icon="dismiss" size="16" />
          </button>
        </div>
      </div>

      <!-- Edit Mode for Satisfaction -->
      <div v-if="editMode.satisfaction" class="edit-form">
        <div class="form-group">
          <label>Rating (1-5)</label>
          <select v-model="editData.satisfaction.rating" class="form-input">
            <option value="">Select rating</option>
            <option value="1">1 - Very Poor</option>
            <option value="2">2 - Poor</option>
            <option value="3">3 - Average</option>
            <option value="4">4 - Good</option>
            <option value="5">5 - Excellent</option>
          </select>
        </div>
        <div class="form-group">
          <label>NPS Score (0-10)</label>
          <select v-model="editData.satisfaction.nps_score" class="form-input">
            <option value="">Select NPS score</option>
            <option v-for="i in 11" :key="i-1" :value="i-1">{{ i-1 }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Feedback</label>
          <textarea 
            v-model="editData.satisfaction.feedback" 
            class="form-input"
            rows="3"
            placeholder="Customer feedback..."
          ></textarea>
        </div>
        <div class="form-group">
          <label>Feedback Category</label>
          <select v-model="editData.satisfaction.feedback_category" class="form-input">
            <option value="">Select category</option>
            <option value="positive">Positive</option>
            <option value="neutral">Neutral</option>
            <option value="negative">Negative</option>
          </select>
        </div>
      </div>

      <!-- Display Mode for Satisfaction -->
      <div v-else>
        <div class="attribute-group" v-if="customerSatisfaction?.rating">
          <div class="attribute-label">Rating</div>
          <div class="attribute-value">
            <span class="rating">{{ customerSatisfaction.rating }}/5</span>
            <span class="stars">{{ getStars(customerSatisfaction.rating) }}</span>
          </div>
        </div>
        <div class="attribute-group" v-if="customerSatisfaction?.nps_score !== undefined">
          <div class="attribute-label">NPS Score</div>
          <div class="attribute-value">
            <span class="badge" :class="getNpsClass(customerSatisfaction.nps_score)">
              {{ customerSatisfaction.nps_score }}/10
            </span>
          </div>
        </div>
        <div class="attribute-group" v-if="customerSatisfaction?.feedback">
          <div class="attribute-label">Feedback</div>
          <div class="attribute-value feedback">{{ customerSatisfaction.feedback }}</div>
        </div>
        <div class="attribute-group" v-if="customerSatisfaction?.feedback_category">
          <div class="attribute-label">Feedback Category</div>
          <div class="attribute-value">
            <span class="badge" :class="getSentimentClass(customerSatisfaction.feedback_category)">
              {{ customerSatisfaction.feedback_category }}
            </span>
          </div>
        </div>
        <div v-if="!customerSatisfaction || Object.keys(customerSatisfaction).length === 0" class="no-data">
          <div class="attribute-value">No satisfaction data recorded</div>
        </div>
      </div>
    </div>

    <!-- Fallback when no content attributes -->
    <div v-if="!hasAnyContentAttributes" class="no-data">
      <div class="attribute-group">
        <div class="attribute-label">Messages</div>
        <div class="attribute-value">{{ conversation.messages?.length || 0 }}</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Response Time</div>
        <div class="attribute-value">N/A</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Last Activity</div>
        <div class="attribute-value">{{ getLastActivityType() }}</div>
      </div>
    </div>

    <!-- Loading indicator -->
    <div v-if="saving" class="loading-overlay">
      <div class="loading-spinner"></div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import ConversationApi from '../../../api/inbox/conversation';

export default {
  name: 'ConversationContentAttributes',
  props: {
    conversation: {
      type: Object,
      required: true,
    },
  },

  data() {
    return {
      editMode: {
        context: false,
        resolution: false,
        satisfaction: false,
      },
      editData: {
        context: {},
        resolution: {},
        satisfaction: {},
      },
      saving: false,
    };
  },
  
  computed: {
    ...mapGetters({
      currentAccountId: 'getCurrentAccountId',
    }),

    contentAttributes() {
      return this.conversation?.content_attributes || {};
    },
    
    hasAnyContentAttributes() {
      return Object.keys(this.contentAttributes).length > 0;
    },
    
    conversationContext() {
      return this.contentAttributes.conversation_context;
    },
    
    interactionPatterns() {
      return this.contentAttributes.interaction_patterns;
    },

    resolutionContext() {
      return this.contentAttributes.resolution_context;
    },

    customerSatisfaction() {
      return this.contentAttributes.customer_satisfaction;
    },
  },

  methods: {
    enableEditMode(section) {
      this.editMode[section] = true;
      this.initializeEditData(section);
    },

    cancelEdit(section) {
      this.editMode[section] = false;
      this.editData[section] = {};
    },

    initializeEditData(section) {
      switch (section) {
        case 'context':
          this.editData.context = {
            channel: this.conversationContext?.channel || '',
            source: this.conversationContext?.source || '',
            priority: this.conversationContext?.priority || '',
            category: this.conversationContext?.category || '',
            tagsString: this.conversationContext?.tags ? this.conversationContext.tags.join(', ') : '',
          };
          break;
        case 'resolution':
          this.editData.resolution = {
            resolution_type: this.resolutionContext?.resolution_type || '',
            topic_category: this.resolutionContext?.topic_category || '',
            complexity_level: this.resolutionContext?.complexity_level || '',
            knowledge_base_used: this.resolutionContext?.knowledge_base_used ?? '',
            follow_up_required: this.resolutionContext?.follow_up_required ?? '',
          };
          break;
        case 'satisfaction':
          this.editData.satisfaction = {
            rating: this.customerSatisfaction?.rating || '',
            nps_score: this.customerSatisfaction?.nps_score ?? '',
            feedback: this.customerSatisfaction?.feedback || '',
            feedback_category: this.customerSatisfaction?.feedback_category || '',
          };
          break;
      }
    },

    async saveSection(section) {
      this.saving = true;
      try {
        const updatedAttributes = { ...this.contentAttributes };
        
        switch (section) {
          case 'context':
            updatedAttributes.conversation_context = {
              ...updatedAttributes.conversation_context,
              channel: this.editData.context.channel,
              source: this.editData.context.source,
              priority: this.editData.context.priority,
              category: this.editData.context.category,
              tags: this.editData.context.tagsString 
                ? this.editData.context.tagsString.split(',').map(tag => tag.trim()).filter(tag => tag)
                : [],
            };
            break;
          case 'resolution':
            updatedAttributes.resolution_context = {
              ...updatedAttributes.resolution_context,
              resolution_type: this.editData.resolution.resolution_type,
              topic_category: this.editData.resolution.topic_category,
              complexity_level: this.editData.resolution.complexity_level,
              knowledge_base_used: this.editData.resolution.knowledge_base_used,
              follow_up_required: this.editData.resolution.follow_up_required,
              timestamp: new Date().toISOString(),
            };
            break;
          case 'satisfaction':
            updatedAttributes.customer_satisfaction = {
              ...updatedAttributes.customer_satisfaction,
              rating: parseInt(this.editData.satisfaction.rating) || undefined,
              nps_score: parseInt(this.editData.satisfaction.nps_score) ?? undefined,
              feedback: this.editData.satisfaction.feedback,
              feedback_category: this.editData.satisfaction.feedback_category,
              timestamp: new Date().toISOString(),
            };
            break;
        }

        // Clean up undefined values
        Object.keys(updatedAttributes).forEach(key => {
          if (updatedAttributes[key] && typeof updatedAttributes[key] === 'object') {
            Object.keys(updatedAttributes[key]).forEach(subKey => {
              if (updatedAttributes[key][subKey] === undefined || updatedAttributes[key][subKey] === '') {
                delete updatedAttributes[key][subKey];
              }
            });
          }
        });

        await ConversationApi.updateContentAttributes({
          accountId: this.currentAccountId,
          conversationId: this.conversation.id,
          contentAttributes: updatedAttributes,
        });

        // Update the conversation in the store
        this.$store.dispatch('conversations/updateConversation', {
          ...this.conversation,
          content_attributes: updatedAttributes,
        });

        this.editMode[section] = false;
        this.editData[section] = {};
        
        this.$toast.success('Content attributes updated successfully');
      } catch (error) {
        console.error('Error updating content attributes:', error);
        this.$toast.error('Failed to update content attributes');
      } finally {
        this.saving = false;
      }
    },

    formatResponseTime(minutes) {
      if (!minutes || minutes === 0) return 'N/A';
      if (minutes < 60) return `${minutes}m`;
      return `${Math.round(minutes / 60)}h`;
    },

    formatDuration(seconds) {
      if (!seconds) return 'N/A';
      if (seconds < 60) return `${seconds}s`;
      if (seconds < 3600) return `${Math.round(seconds / 60)}m`;
      return `${Math.round(seconds / 3600)}h`;
    },

    getPriorityClass(priority) {
      const classes = {
        low: 'badge--success',
        medium: 'badge--warning',
        high: 'badge--danger',
        urgent: 'badge--alert'
      };
      return classes[priority] || 'badge--secondary';
    },

    getSentimentClass(sentiment) {
      const classes = {
        positive: 'badge--success',
        neutral: 'badge--info',
        negative: 'badge--danger',
        frustrated: 'badge--alert'
      };
      return classes[sentiment] || 'badge--secondary';
    },
    
    getResolutionClass(type) {
      const classes = {
        solved: 'badge--success',
        pending: 'badge--warning',
        escalated: 'badge--danger',
        closed: 'badge--info'
      };
      return classes[type] || 'badge--secondary';
    },

    getNpsClass(score) {
      if (score >= 9) return 'badge--success';
      if (score >= 7) return 'badge--warning';
      return 'badge--danger';
    },

    getStars(rating) {
      const fullStars = Math.floor(rating);
      const hasHalfStar = rating % 1 >= 0.5;
      let stars = '★'.repeat(fullStars);
      if (hasHalfStar) stars += '☆';
      const emptyStars = 5 - Math.ceil(rating);
      stars += '☆'.repeat(emptyStars);
      return stars;
    },

    getLastActivityType() {
      if (!this.conversation.messages || this.conversation.messages.length === 0) {
        return 'N/A';
      }
      const lastMessage = this.conversation.messages[this.conversation.messages.length - 1];
      return lastMessage.message_type === 1 ? 'outgoing' : 'incoming';
    },

    getResponseTime() {
      if (this.interactionPatterns.agent_response_time && this.interactionPatterns.agent_response_time > 0) {
        return this.formatResponseTime(this.interactionPatterns.agent_response_time);
      } else if (this.interactionPatterns.customer_response_time && this.interactionPatterns.customer_response_time > 0) {
        return this.formatResponseTime(this.interactionPatterns.customer_response_time);
      } else if (this.interactionPatterns.response_time_avg && this.interactionPatterns.response_time_avg > 0) {
        return this.formatResponseTime(this.interactionPatterns.response_time_avg);
      } else {
        return 'N/A';
      }
    },
  }
};
</script>

<style scoped>
.content-attributes-inner {
  padding: 16px 20px 12px 20px;
  position: relative;
}

.section {
  margin-bottom: 24px;
}

.section:last-child {
  margin-bottom: 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.section-title {
  font-size: 12px;
  color: #9ca3af;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  border-bottom: 1px solid #374151;
  padding-bottom: 4px;
  flex: 1;
}

.auto-label {
  font-size: 10px;
  color: #6b7280;
  font-weight: 400;
  text-transform: none;
}

.edit-button {
  background: none;
  border: none;
  color: #9ca3af;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s;
}

.edit-button:hover {
  color: #3b82f6;
  background: rgba(59, 130, 246, 0.1);
}

.edit-actions {
  display: flex;
  gap: 4px;
}

.save-button, .cancel-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s;
}

.save-button {
  color: #10b981;
}

.save-button:hover {
  background: rgba(16, 185, 129, 0.1);
}

.save-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.cancel-button {
  color: #ef4444;
}

.cancel-button:hover {
  background: rgba(239, 68, 68, 0.1);
}

.edit-form {
  background: #1f2937;
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
  color: #d1d5db;
  font-weight: 500;
  margin-bottom: 4px;
}

.form-input {
  width: 100%;
  background: #374151;
  border: 1px solid #4b5563;
  border-radius: 6px;
  padding: 8px 12px;
  color: #f9fafb;
  font-size: 14px;
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
}

.form-input option {
  background: #374151;
  color: #f9fafb;
}

textarea.form-input {
  resize: vertical;
  min-height: 60px;
}

.attribute-group {
  margin-bottom: 12px;
}

.attribute-label {
  font-size: 13px;
  color: #b3b8c2;
  font-weight: 500;
  margin-bottom: 2px;
}

.attribute-value {
  font-size: 15px;
  color: #fff;
  word-break: break-word;
}

.feedback {
  font-style: italic;
  font-size: 13px;
  line-height: 1.4;
}

.rating {
  font-weight: 600;
  margin-right: 8px;
}

.stars {
  color: #fbbf24;
  font-size: 14px;
}

.tag {
  display: inline-block;
  background: #374151;
  color: #d1d5db;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 11px;
  margin-right: 4px;
  margin-bottom: 4px;
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
.badge--info { background: #dbeafe; color: #1e40af; }
.badge--alert { background: #fed7d7; color: #c53030; }
.badge--secondary { background: #f3f4f6; color: #374151; }

.no-data {
  opacity: 0.7;
  font-style: italic;
  color: #9ca3af;
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
  border: 2px solid #374151;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
