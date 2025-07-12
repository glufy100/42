/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_putstr.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: codespace <codespace@student.42.fr>        +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/12 08:35:21 by codespace         #+#    #+#             */
/*   Updated: 2025/07/12 08:41:29 by codespace        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>

void	ft_putstr(char *str)
{
    int i;

    i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
        i++;
	}
}

/*
int main()
{
	char test[] = "salut";
    ft_putstr(test);
}
*/
