#include <iostream>
#include <stdio.h>
#include <vector>
#include <string.h>
#include <fstream>
#include <time.h>

typedef char* type;

int const Num_of_words = 2000;
int const Size_of_table = 1000;

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

int hash_func(char* first_symbol);

int show_lists_sizes(std::vector <LIST>& hash_table, FILE* output);

char* find_word(int hash, std::vector <LIST>& hash_table, char* word);

int finding_words(char* text, int file_size, FILE* output);

extern "C"
{
	int hash_with_asm(char* first_letter, int const Size_of_table);
}


int main()
{
	int time_start = clock();

	FILE* input = nullptr;
	FILE* output = nullptr;

	fopen_s(&input, "word_bank_1000.txt", "r");
	fopen_s(&output, "word_hash_new.csv", "w");

	if (!input || !output)
		return 1;

	fseek(input, 0, SEEK_END);
	long file_size = ftell(input);
	fseek(input, 0, SEEK_SET);

	char* text = (char*)calloc(file_size, sizeof(char));

	if (!text)
		return 2;

	fread(text, sizeof(char), file_size, input);

	finding_words(text, file_size, output);

	printf("%d", clock() - time_start);

	return 0;
}


int finding_words(char* text, int file_size, FILE* output)
{
	std::vector <LIST> hash_table(Size_of_table);
	std::vector <char*> words;

	for (int i = 0; i < file_size; ++i)
	{
		if (text[i] == '\r')
			text[i] = 0;
	}

	for (int i = 0; i < file_size; ++i)
	{
		if (i == 0 || text[i - 1] == '\n')
		{
			hash_table[hash_with_asm(&text[i], Size_of_table)].push_front(&text[i]);
			words.push_back(&text[i]);
		}
	}

	for (int i = 0; i < Size_of_table; ++i)
		fprintf(output, "%d\n", hash_table[i].size);

	for (long long i = 0; i < 1200000; ++i)
	{
		int hash = hash_with_asm(words[i % Num_of_words], Size_of_table);

		find_word(hash, hash_table, words[i % Num_of_words]);
	}

	return 0;
}


int show_lists_sizes(std::vector <LIST>& hash_table, FILE* output)
{
	for (int i = 0; i < Size_of_table; ++i)
		fprintf(output, "%d\n", hash_table[i].size);

	return 0;
}

int hash_func(char* first_letter)
{
	int hash = 5381;

	for (char* cur_letter = first_letter; *cur_letter != 0; ++cur_letter)
		hash = ((hash << 3) + hash) + *cur_letter;

	int table_hash = hash % Size_of_table;

	return table_hash;
}


char* find_word(int hash, std::vector <LIST>& hash_table, char* word)
{
	int list_size = hash_table[hash].size;

	LIST::NODE* cur_node = hash_table[hash].head;

	int right_word = 0;

	int  word_in_list = 0;

	for (word_in_list = 0; word_in_list < list_size && strcmp(cur_node->data, word); ++word_in_list)
		cur_node = cur_node->next;

	if (word_in_list < list_size)
		return cur_node->data;

	return nullptr;
}


int asm_inline_hash(char* first_letter)
{
	_asm
	{
		mov ecx, first_letter
		mov ebx, 5381

		hash_start:
		cmp byte ptr[ecx], 0
			je hash_end
			mov edx, ebx
			rol ebx, 5
			add ebx, edx
			add ebx, [ecx]
			inc ecx
			jmp hash_start
			hash_end :

		xor edx, edx
			mov eax, ebx
			mov ecx, Size_of_table
			div ecx
			mov eax, edx
	}
}