// app/javascript/task_modals.js

function initTimeFieldToggle(prefix) {
  const fixedRadio     = document.getElementById(`${prefix}_fixed_time`);
  const preferredRadio = document.getElementById(`${prefix}_preferred_time`);
  const fixedField     = document.getElementById(`${prefix}FixedTimeField`);
  const preferredField = document.getElementById(`${prefix}PreferredTimeField`);

  if (!fixedRadio) return;

  function toggle() {
    fixedField.style.display     = fixedRadio.checked ? 'block' : 'none';
    preferredField.style.display = preferredRadio.checked ? 'block' : 'none';
  }

  fixedRadio.addEventListener('change', toggle);
  preferredRadio.addEventListener('change', toggle);
  toggle();
}

function populateEditModal(event) {
  event.preventDefault();
  const link = event.currentTarget;

  const form = document.getElementById('editTaskForm');
  form.action = `/schedules/${link.dataset.scheduleId}/tasks/${link.dataset.taskId}`;

  document.getElementById('task_category').value     = link.dataset.taskTitle;
  document.getElementById('task_duration_min').value = link.dataset.taskDuration;

  const timeType = link.dataset.taskType;
  const timeValue = link.dataset.taskTime;

  if (timeType === 'fixed_time') {
    document.getElementById('edit_fixed_time').checked = true;
    document.getElementById('task_fixed_time').value   = timeValue;
  } else {
    document.getElementById('edit_preferred_time').checked = true;
    document.getElementById('task_preferred_time').valu
