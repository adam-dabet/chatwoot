<template>
  <div class="content-attributes-inner">
    <!-- Conversation Context Section -->
    <div v-if="conversationContext" class="section">
      <div class="section-header">
        <div class="section-title">Conversation Context</div>
      </div>
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

    <!-- Interaction Patterns Section (Read-only) -->
    <div v-if="interactionPatterns" class="section">
      <div class="section-header">
        <div class="section-title">Interaction Patterns</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Messages</div>
        <div class="attribute-value">{{ interactionPatterns.messages_count || 'N/A' }}</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Response Time</div>
        <div class="attribute-value">{{ formatResponseTime(interactionPatterns.agent_response_time) }}</div>
      </div>
      <div class="attribute-group">
        <div class="attribute-label">Last Activity</div>
        <div class="attribute-value">{{ interactionPatterns.last_activity_type || 'N/A' }}</div>
      </div>
    </div>

    <!-- Resolution Context Section -->
    <div v-if="resolutionContext" class="section">
      <div class="section-header">
        <div class="section-title">Resolution Context</div>
      </div>
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
    </div>

    <!-- Customer Satisfaction Section -->
    <div v-if="customerSatisfaction" class="section">
      <div class="section-header">
        <div class="section-title">Customer Satisfaction</div>
      </div>
      <div class="attribute-group" v-if="customerSatisfaction?.rating">
        <div class="attribute-label">Rating</div>
        <div class="attribute-value">
          <span class="stars">{{ getStars(customerSatisfaction.rating) }}</span>
          <span class="rating-number">({{ customerSatisfaction.rating }}/5)</span>
        </div>
      </div>
      <div class="attribute-group" v-if="customerSatisfaction?.nps_score !== undefined">
        <div class="attribute-label">NPS Score</div>
        <div class="attribute-value">
          <span class="badge" :class="getNpsClass(customerSatisfaction.nps_score)">
            {{ customerSatisfaction.nps_score }}
          </span>
        </div>
      </div>
      <div class="attribute-group" v-if="customerSatisfaction?.feedback">
        <div class="attribute-label">Feedback</div>
        <div class="attribute-value">{{ customerSatisfaction.feedback }}</div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="!hasAnyAttributes" class="empty-state">
      <div class="empty-message">No content attributes available</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConversationContentAttributes',
  props: {
    conversation: {
      type: Object,
      required: true,
    },
  },

  computed: {
    contentAttributes() {
      return this.conversation.content_attributes || {};
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

    hasAnyAttributes() {
      return this.conversationContext || 
             this.interactionPatterns || 
             this.resolutionContext || 
             this.customerSatisfaction;
    },
  },

  methods: {
    formatResponseTime(minutes) {
      if (!minutes || minutes === 0) return 'N/A';
      if (minutes < 60) return `${minutes}m`;
      return `${Math.round(minutes / 60)}h`;
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

.attribute-group {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
  min-height: 20px;
}

.attribute-group:last-child {
  margin-bottom: 0;
}

.attribute-label {
  font-size: 12px;
  color: #d1d5db;
  font-weight: 500;
  flex: 0 0 auto;
  margin-right: 12px;
  min-width: 80px;
}

.attribute-value {
  font-size: 12px;
  color: #f9fafb;
  text-align: right;
  flex: 1;
  word-break: break-word;
}

.badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge--success {
  background: rgba(16, 185, 129, 0.2);
  color: #10b981;
}

.badge--warning {
  background: rgba(245, 158, 11, 0.2);
  color: #f59e0b;
}

.badge--danger {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.badge--info {
  background: rgba(59, 130, 246, 0.2);
  color: #3b82f6;
}

.badge--alert {
  background: rgba(168, 85, 247, 0.2);
  color: #a855f7;
}

.badge--secondary {
  background: rgba(107, 114, 128, 0.2);
  color: #6b7280;
}

.tag {
  display: inline-block;
  background: #374151;
  color: #d1d5db;
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 10px;
  margin-left: 4px;
}

.tag:first-child {
  margin-left: 0;
}

.stars {
  color: #fbbf24;
  font-size: 14px;
  margin-right: 4px;
}

.rating-number {
  color: #9ca3af;
  font-size: 10px;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
}

.empty-message {
  color: #6b7280;
  font-size: 14px;
  font-style: italic;
}
</style> 