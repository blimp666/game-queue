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
  def push(message_name, message_body)
    $redis.lpush(queue_name, [message_name.to_s, message_body].to_s)
  end

  # См. push
  def async_push(*params)
    Thread.new { push *params }
  end


  # ==== Returns
  # <Array[String, Object]>::
  def pop
    result = $redis.rpop(queue_name)
    eval(result) if result
  end

end
