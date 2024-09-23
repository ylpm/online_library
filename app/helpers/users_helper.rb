module UsersHelper
  def avatar(user=current_user, css_class: "avatar", width: 32, height: 32)
    return nil unless user
    image_tag(user.primary_image, alt: user.first_name, class: "#{css_class}" , width: width, height: height) if user.primary_image
  end

	def gravatar(email_address=current_session.email_address_identifier || current_user.primary_email_address, size: 80, css_class: "gravatar", width: 32, height: 32 )
	  return nil unless email_address
    gravatar_id = Digest::MD5::hexdigest(email_address.address.downcase)
	  gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}&d=wavatar"
    # Posibles valores para parámetro d en gravatar_url:
    # -               404: Devuelve una respuesta 404 si no hay identidad (sin imagen).
    # -                mm: Imagen predeterminada "mistery man".
    # -         identicon: Genera un icono basado en el hash de la dirección de correo electrónico.
    # -         monsterid: Genera una imagen de tipo monsterid.
    # -           wavatar: Genera una imagen de tipo wavatar.
    # - URL de una imagen: Puedes usar una URL personalizada de una imagen que deseas usar como predeterminada.
	  image_tag(gravatar_url, alt: email_address.owner.first_name, class: "#{css_class} #{email_address.gravatar_style}" , width: width, height: height)
	end
end
