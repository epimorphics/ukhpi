# Raised when the user's request cannot be understood, typically because their
# selections failed validation. Mapped to 400 in config/application.rb.
class BadRequestError < ApplicationRequestError
end
