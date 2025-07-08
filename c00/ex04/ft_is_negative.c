/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_is_negative.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: lerb <lerb@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/08 11:56:44 by lerb              #+#    #+#             */
/*   Updated: 2025/07/08 12:10:32 by lerb             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

void	ft_is_negative(int n)
{
	if (n < 0)
	{
		write(1, "the number is negqtive", 23);
	}
	else if (n > 0)
	{
		write(1, "the number is possitive", 24);
	}
	else
	{
		write(1, "pls input a valide number", 24);
	}
}
