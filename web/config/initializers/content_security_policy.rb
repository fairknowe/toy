# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

initial_frame_ancestors = [ "*.myshopify.com", "https://admin.shopify.com", "https://fki.ngrok.io", "localhost:3001" ]

def current_domain
  shopify_domain = params[:shop] || params[:myshopify_domain]
  current_domain ||= shopify_domain && ShopifyApp::Utils.sanitize_shop_domain(shopify_domain)
rescue StandardError => e
  Rails.logger.error("[#{self.class}] - Line #{__LINE__}: in content_security_policy.rb current_domain error: #{e.message}")
  nil
end

frame_ancestors = -> { current_domain ? [ "https://#{current_domain}", "https://admin.shopify.com", "https://fki.ngrok.io" ] : initial_frame_ancestors }

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.frame_ancestors(frame_ancestors)
    # policy.upgrade_insecure_requests(true)
    # policy.default_src :https, :self
    # policy.style_src :self, :https, -> { "'nonce-#{SecureRandom.base64(16)}'" }
    # Allow @vite/client to hot reload style changes in development
    #    policy.style_src *policy.style_src, :unsafe_inline if Rails.env.development?

    # policy.style_src(:https, :self, "cdn.shopifycloud.com")
    #   policy.script_src(:https, "'unsafe-inline'", "cdn.shopifycloud.com", "https://darling-formally-fox.ngrok-free.app")
    # Allow @vite/client to hot reload javascript changes in development
    #    policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

    # You may need to enable this in production as well depending on your setup.
    #    policy.script_src *policy.script_src, :blob if Rails.env.test?

    #   policy.img_src(:self, :https, :data, "cdn.shopifycloud.com", "https://darling-formally-fox.ngrok-free.app")
  end
  # # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  # config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
  # config.content_security_policy_nonce_directives = %w[script-src style-src]

  # # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
