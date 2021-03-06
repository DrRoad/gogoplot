add_geom_point <- function(p, fields, size, color) {
  # validate size inputs
  req_size_inputs <- c("size_mapping_enabled", "size_map", "size_set")
  if (!all(req_size_inputs %in% names(size)))
    stop("some required size input fields are missing")
  if (!is.logical(size$size_mapping_enabled))
    stop("size_mapping_enabled must be a logical value")
  # validate color inputs
  req_color_inputs <- c("alpha", "color_mapping_enabled",
                       "color_map", "color_set", "color_discrete")
  if (!all(req_color_inputs %in% names(color)))
    stop("some required color input fields are missing")
  if (!is.logical(color$color_mapping_enabled))
    stop("color_mapping_enabled must be a logical value")
  if (!is.logical(color$color_discrete))
    stop("color_discrete must be a logical value")

  # build up list of "mapping" and "setting" expressions
  # which will go into a ggplot2 layer at the end
  mapping <- rlang::exprs()
  setting <- rlang::exprs()

  # COLOR
  if (color$color_mapping_enabled) {
    if (color$color_map != CONST_NONE) {
      color_expr <- if_else_expr(color$color_discrete == TRUE,
                                 rlang::expr(as.factor(!!sym(color$color_map))),
                                 rlang::expr(!!sym(color$color_map)))
      mapping <- append_exprs(mapping, color = !!(color_expr))
    }
  } else {
    if (color$color_set != CONST_NONE)
      setting <- append_exprs(setting, color = !!color$color_set)
  }

  # ALPHA
  if (color$alpha != 1)
    setting <- append_exprs(setting, alpha = !!as.numeric(color$alpha))

  # SIZE
  if (size$size_mapping_enabled) {
    if (size$size_map != CONST_NONE)
      mapping <- append_exprs(mapping, size = !!sym(size$size_map))
  } else {
    if (size$size_set != CONST_DEFAULT_POINT_SIZE)
      setting <- append_exprs(setting, size = !!as.numeric(size$size_set))
  }

  # compile expressions into layer
  if (length(mapping) > 0) {
    p <- p %++% geom_point(aes(!!!mapping), !!!setting)
  } else {
    p <- p %++% geom_point(!!!setting)
  }
  p
}
