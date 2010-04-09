module SimpleAuth
  module Helper
    # Renders the specified block for logged users.
    #
    #   <% when_logged do %>
    #     <!-- content for logged users -->
    #   <% end %>
    def when_logged(&block)
      capture(&block) if logged_in?
    end
  end
end