# Minimal content attributes functionality for PR #1
# Add these methods to the existing Conversation model

class Conversation < ApplicationRecord
  # ... existing code ...

  # Content attributes getter
  def get_content_attribute(key)
    content_attributes&.dig(key.to_s)
  end

  # Content attributes setter
  def set_content_attribute(key, value)
    self.content_attributes = (content_attributes || {}).merge(key.to_s => value)
  end

  # Track conversation context
  def track_conversation_context(context_data)
    context = {
      channel: context_data[:channel],
      source: context_data[:source],
      priority: context_data[:priority],
      category: context_data[:category],
      tags: context_data[:tags] || []
    }
    
    set_content_attribute('conversation_context', context)
  end

  # Set resolution context
  def set_resolution_context(topic_category, complexity_level, resolution_type)
    resolution = {
      topic_category: topic_category,
      complexity_level: complexity_level,
      resolution_type: resolution_type,
      resolution_time: Time.current - created_at
    }
    
    set_content_attribute('resolution_context', resolution)
  end

  # Set customer satisfaction
  def set_customer_satisfaction(rating, nps_score, feedback, feedback_category)
    satisfaction = {
      rating: rating,
      nps_score: nps_score,
      feedback: feedback,
      feedback_category: feedback_category,
      collected_at: Time.current
    }
    
    set_content_attribute('customer_satisfaction', satisfaction)
  end

  # Basic interaction patterns (static for now)
  def set_interaction_patterns(patterns)
    set_content_attribute('interaction_patterns', patterns)
  end

  private

  # Validate content attributes structure
  def validate_content_attributes_structure
    return if content_attributes.blank?
    
    allowed_keys = %w[conversation_context interaction_patterns resolution_context customer_satisfaction]
    invalid_keys = content_attributes.keys - allowed_keys
    
    if invalid_keys.any?
      errors.add(:content_attributes, "contains invalid keys: #{invalid_keys.join(', ')}")
    end
  end

  # Include content_attributes in JSON responses
  def as_json(options = {})
    super(options).tap do |json|
      json['content_attributes'] = content_attributes if respond_to?(:content_attributes)
    end
  end
end 