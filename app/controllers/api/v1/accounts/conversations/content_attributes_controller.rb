module Api
  module V1
    module Accounts
      module Conversations
        class ContentAttributesController < Api::V1::Accounts::Conversations::BaseController
          def create
            @conversation.update!(content_attributes: permitted_params[:content_attributes])
            render json: @conversation
          end

          def update
            category = permitted_params[:category]
            attributes = permitted_params[:attributes]

            unless @conversation.validate_content_attribute_category(category)
              return render json: { error: 'Invalid category' }, status: :unprocessable_entity
            end

            unless @conversation.validate_content_attribute_values(category, attributes)
              return render json: { error: 'Invalid attribute values' }, status: :unprocessable_entity
            end

            @conversation.update_category_attributes(category, attributes)
            render json: @conversation
          end

          private

          def permitted_params
            params.permit(:category, content_attributes: {}, attributes: {})
          end
        end
      end
    end
  end
end 