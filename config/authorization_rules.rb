authorization do
  role :manager do
    has_permission_on :employees, :to => :manage
    has_permission_on :shifts, :to => :manage
  end
  role :employee do
    has_permission_on :shifts, :to => :read
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
