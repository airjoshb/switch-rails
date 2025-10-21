# For more information regarding these settings check out our docs https://docs.avohq.io
Avo.configure do |config|
  ## == Routing ==
  config.root_path = '/avo'

  # Where should the user be redirected when visting the `/avo` url
  config.home_path = '/avo/resources/customer_orders'

  ## == Licensing ==
  config.license = 'community' # change this to 'pro' when you add the license key
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Set the context ==
  config.set_context do
    # Return a context object that gets evaluated in Avo::ApplicationController
  end

  ## == Authentication ==
  config.current_user_method do
    Current.user
  end

  config.current_user_resource_name = :current_user

  config.authenticate_with do
    if session = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session
    else
      redirect_to '/sign_in'
    end
  end

  config.sign_out_path_name = 'session_path(current_user)'

  ## == Authorization ==
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  # }
  # config.raise_error_on_missing_policy = false
  config.authorization_client = nil

  ## == Localization ==
  # config.locale = 'en-US'

  ## == Resource options ==
  config.resource_controls_placement = :left
  # config.model_resource_mapping = {}
  # config.default_view_type = :table
  config.per_page = 24
  # config.per_page_steps = [12, 24, 48, 72]
  config.via_per_page = 24
  # config.id_links_to_resource = true
  # config.cache_resources_on_index_view = true
  ## permanent enable or disable cache_resource_filters, default value is false
  # config.cache_resource_filters = false
  ## provide a lambda to enable or disable cache_resource_filters per user/resource.
  # config.cache_resource_filters = ->(current_user:, resource:) { current_user.cache_resource_filters?}

  ## == Customization ==
  # config.app_name = 'Avocadelicious'
  # config.timezone = 'UTC'
  # config.currency = 'USD'
  # config.hide_layout_when_printing = false
  # config.full_width_container = false
  # config.full_width_index_view = false
  # config.search_debounce = 300
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true
  # config.disabled_features = []
  # config.resource_controls = :right
  config.tabs_style = :pills # can be :tabs or :pills
  # config.buttons_on_form_footers = true
  # config.field_wrapper_layout = true

  ## == Branding ==
  config.branding = {
  #   colors: {
  #     background: "248 246 242",
  #     100 => "#CEE7F8",
  #     400 => "#399EE5",
  #     500 => "#0886DE",
  #     600 => "#066BB2",
  #   },
  #   chart_colors: ["#0B8AE2", "#34C683", "#2AB1EE", "#34C6A8"],
    logo: "logo.png",
    logomark: "switch-bakery-gluten-free-bread.png"
  #   placeholder: "/avo-assets/placeholder.svg"
  }

  ## == Breadcrumbs ==
  config.display_breadcrumbs = true
  config.set_initial_breadcrumbs do
    add_breadcrumb "Home", '/avo/resources/customer_orders'
  end

  ## == Menus ==
  # config.main_menu = -> {
  #   section "Dashboards", icon: "dashboards" do
  #     all_dashboards
  #   end

  #   section "Resources", icon: "resources" do
  #     all_resources
  #   end

  #   section "Tools", icon: "tools" do
  #     all_tools
  #   end
  # }
  # config.profile_menu = -> {
  #   link "Profile", path: "/avo/profile", icon: "user-circle"
  # }
end
