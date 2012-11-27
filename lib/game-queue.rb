# -*- coding: utf-8 -*-
# Либа, добавляет и ивлекает сообщения из общей глобальной очереди сообщений
# В конфиге:
# GameQueue.redis = $redis
# GameQueue.queue_name = 'skyburg_main_queue'
#
# Добавление сообщений
# GameQueue.push(:combat_created, {some: 'fucking', super: 'params'})
#
# Получение сообещений
# GameQueue.pop
class GameQueue
  require 'singleton'
  include Singleton
  attr_accessor :redis, :queue_name

  def self.method_missing(method_name, *params)
    instance.send(method_name, *params)
  end

  # ==== Parameters
  # message_name<String>: тип сообщения
  # message_body<Object>:: любой ruby объект с простыми данными, хэш, массив, число, строка...
  # errors_counter<Integer>:: счетчик ошибок, которые возникают при попытке обработать взятую из очереди запись
  # если запись после этого снова возвращается в очередь, его следует увеличить.
  def push(message_name, message_body, errors_counter = 0)
    redis.lpush(queue_name, Marshal.dump([message_name.to_s, message_body, errors_counter]))
  end

  # Сделать отложенный асинхронный push
  # ==== Parameters
  # delay<Integer>:: время задержки в секундах
  # params  (См. push)
  def async_push_with_delay(delay, *params)
    Thread.new { sleep delay; push *params }
  end

  # См. push
  def async_push(*params)
    async_push_with_delay(0, params)
  end


  # ==== Returns
  # <Array[String, Object, Integer]>::
  def pop
    result = redis.rpop(queue_name)
    Marshal.load(result) if result
  end

  # ==== Description
  # очищает всю очередь
  def clean!
    redis.del(queue_name)
  end

end
