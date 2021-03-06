require 'spec_helper'

describe 'Defining one-to-many association' do
  include_context 'users and tasks'

  before do
    conn[:users].insert id: 2, name: 'Jane'
    conn[:tasks].insert id: 2, user_id: 2, title: 'Task one'

    configuration.mappers do
      define(:users)

      define(:with_tasks, parent: :users) do
        group tasks: [:tasks_id, :title]
      end
    end

    configuration.relation(:tasks) { use :assoc_macros }
  end

  it 'extends relation with association methods' do
    configuration.relation(:users) do
      use :assoc_macros

      one_to_many :tasks, key: :user_id, on: { title: 'Finish ROM' }

      def by_name(name)
        where(name: name)
      end

      def with_tasks
        association_left_join(:tasks, select: [:id, :title])
      end

      def all
        select(:id, :name)
      end
    end

    users = container.relations.users

    expect(users.with_tasks.by_name("Piotr").to_a).to eql(
      [{ id: 1, name: 'Piotr', tasks_id: 1, title: 'Finish ROM' }]
    )

    result = container.relation(:users).map_with(:with_tasks)
             .all.with_tasks.by_name("Piotr").to_a

    expect(result).to eql(
      [{ id: 1, name: 'Piotr', tasks: [{ tasks_id: 1, title: 'Finish ROM' }] }]
    )
  end

  it 'allows setting :conditions' do
    configuration.relation(:users) do
      use :assoc_macros

      one_to_many :piotrs_tasks, relation: :tasks, key: :user_id,
                                 conditions: { name: 'Piotr' }

      def with_piotrs_tasks
        association_left_join(:piotrs_tasks, select: [:id, :title])
      end

      def all
        select(:id, :name)
      end
    end

    users = container.relations.users

    expect(users.with_piotrs_tasks.to_a).to eql(
      [{ id: 1, name: 'Piotr', tasks_id: 1, title: 'Finish ROM' }]
    )

    result = container.relation(:users).map_with(:with_tasks)
             .all.with_piotrs_tasks.to_a

    expect(result).to eql(
      [{ id: 1, name: 'Piotr', tasks: [{ tasks_id: 1, title: 'Finish ROM' }] }]
    )
  end
end
