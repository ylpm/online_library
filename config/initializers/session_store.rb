Rails.application.config.session_store :cookie_store, key: '_online_library_session',
                                                      httponly: true,
                                                      secure: Rails.env.production? # ? :strict : false