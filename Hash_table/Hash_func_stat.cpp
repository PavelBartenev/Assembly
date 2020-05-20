#include <iostream>
#include <stdio.h>
#include <vector>
#include <string>
#include <fstream>

typedef std::string type;

int const Num_of_words = 2000;
int const Size_of_table = 500;

class LIST
{
public:
	class NODE
	{
	public:
		type data;
		NODE* prev;
		NODE* next;

		NODE() : data{ 0 }, prev{ nullptr }, next{ nullptr } {}
	};

	int size;
	NODE* head;
	NODE* tail;

	LIST() : size{ 0 }, head{ nullptr }, tail{ nullptr } {}

	int push_back(type data)
	{
		NODE* new_node = new NODE;

		if (!new_node)
			return(-1);

		new_node->data = data;

		if (!head)
		{
			new_node->next = nullptr;
			new_node->prev = nullptr;

			head = new_node;
			tail = new_node;

			size++;

			return 0;
		}

		new_node->next = nullptr;
		new_node->prev = tail;

		tail->next = new_node;

		tail = new_node;

		size++;

		return 0;
	}

	int push_front(type data)
	{
		NODE* new_node = new NODE;

		if (!new_node)
			return(-2);

		new_node->data = data;

		if (!head)
		{
			new_node->next = nullptr;
			new_node->prev = nullptr;

			head = new_node;
			tail = new_node;

			size++;

			return 0;
		}

		new_node->next = head;
		new_node->prev = nullptr;

		head->prev = new_node;

		head = new_node;

		size++;

		return 0;
	}

	int push(type data, int number)
	{
		if (number < 0)
			return(-3);

		if (number >= size)
		{
			//printf("No node with such number: %d", number);
			push_back(data);

			return 0;
		}

		if (number == 0)
		{
			push_front(data);

			return 0;
		}

		NODE* new_node = new NODE;

		if (!new_node)
			exit(-4);

		new_node->data = data;

		NODE* current = search(number - 1);

		new_node->prev = current;
		new_node->next = current->next;

		current->next->prev = new_node;
		current->next = new_node;

		size++;

		return 0;
	}

	type pop_back()
	{
		type data = tail->data;

		NODE* del = tail;

		if (tail->prev != nullptr)
		{
			tail = tail->prev;
			tail->next = nullptr;
		}
		else
		{
			head = nullptr;
			tail = nullptr;
		}

		free(del);

		size--;

		return data;
	}

	type pop_front()
	{
		type data = head->data;

		NODE* del = head;

		if (head->next != nullptr)
		{
			head = head->next;
			head->prev = nullptr;
		}
		else
		{
			head = nullptr;
			tail = nullptr;
		}

		free(del);

		size--;

		return data;
	}

	type pop(int number)
	{
		if (number == size - 1)
			return (pop_back());

		if (number == 0)
			return (pop_front());

		NODE* current = search(number);

		type data = current->data;

		current->prev->next = current->next;
		current->next->prev = current->prev;

		free(current);

		size--;

		return data;
	}

	NODE* search(int number)
	{
		if ((number >= size) || (number < 0))
			return 0;

		NODE* current = head;

		for (int i = 0; i < number; i++)
			current = current->next;

		return current;
	}

	int change(type data, int number)
	{
		NODE* current = search(number);

		current->data = data;

		return 0;
	}

	type get_data(int number)
	{
		NODE* current = search(number);

		return (current->data);
	}
};

long long hash_func(std::string& word, int mode);

int main()
{
	std::ifstream input("word_bank_1000.txt");
	std::ofstream output("hash.csv");

	std::vector<LIST> hash_table(Size_of_table);

	std::string cur_word;

	int hash_mode = 0;
	std::cin >> hash_mode;

	for (int i = 0; i < Num_of_words; ++i)
	{
		input >> cur_word;
		hash_table[hash_func(cur_word, hash_mode) % Size_of_table].push_front(cur_word);
	}

	for (int i = 0; i < Size_of_table; ++i)
		output << hash_table[i].size << "\n";
	
	return 0;
}

long long hash_func(std::string& word, int mode)
{
	switch (mode)
	{
	case 1:
		return 1;
	case 2:
		return word.length();
	case 3:
	{
		int length = word.length();

		int ascii_sum = 0;

		for (int i = 0; i < length; ++i)
			ascii_sum += word[i];

		return ascii_sum;
	}
	case 4:
	{
		int length = word.length();

		int ascii_sum = 0;

		for (int i = 0; i < length; ++i)
			ascii_sum += word[i];

		return (ascii_sum / length);
	}
	case 6:
	{
		int length = word.length();

		long long hash = 5801;

		for (int i = 0; i < length; ++i)
			hash = (hash << 3) + hash + word[i];

		return hash;
	}
	}

	return 0;
}