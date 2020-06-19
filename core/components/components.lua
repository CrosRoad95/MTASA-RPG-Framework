local components = {}
local elementsComponents = {}

local function onElementDestroy()
  local elementComponents = getElementComponents(source)
  for i,componentName in ipairs(elementComponents)do
    removeComponentComponent(source, componentName)
  end
end

function registerComponent(component)
  if(not component.name)then
    return false
  end
  components[component.name] = component
end

function isComponent(componentName)
  return components[componentName] and true or false
end

function doesElementSupportComponent(element, componentName)
  if(not isElement(element))then
    return false
  end

  if(not isComponent(componentName))then
    return false
  end

  local component = components[componentName]
  local elementType = getElementType(element)
  for i,v in ipairs(component.supportedElementsType)do
    if(v == elementType)then
      return true
    end
  end
  return false
end

function addElementComponent(element, componentName)
  if(not isElement(element))then
    return false
  end

  if(not isComponent(componentName))then
    return false
  end

  if(not doesElementSupportComponent(element, componentName))then
    return false
  end

  if(hasElementComponent(element, componentName))then
    return false
  end
  if(not elementsComponents[element])then
    elementsComponents[element] = {}
    addEventHandler("onElementDestroy", element, onElementDestroy)
  end
  local elementComponents = elementsComponents[element]
  elementComponents[componentName] = {}
  components[componentName].onMount(element)
  return true
end

function removeElementComponent(element, componentName)
  if(not isComponent(componentName))then
    return false
  end

  if(not isElement(element))then
    return false
  end
  
  if(not hasElementComponent(element, componentName))then
    return false
  end

  components[componentName].onUnmount(element)
  elementsComponents[element][componentName] = nil
  local elementComponents = getElementComponents(element)
  if(type(elementComponents) == "table" and #elementComponents == 0)then
    elementsComponents[element] = nil
    removeEventHandler("onElementDestroy", element, onElementDestroy)
  end
  return true
end

function hasElementComponent(element, componentName)
  if(not isElement(element))then
    return false
  end
  
  if(not isComponent(componentName))then
    return false
  end

  if(not elementsComponents[element])then
    return false
  end

  return elementsComponents[element][componentName] and true or false
end

function getElementComponents(element)
  if(not isElement(element))then
    return false
  end

  if(not elementsComponents[element])then
    return {} -- brak komponentów
  end

  local elementComponents = elementsComponents[element]
  local t = {}
  for componentName, data in pairs(elementComponents)do
    t[#t + 1] = componentName
  end
  return componentName
end

function clearAllComponents()
  for element, components in pairs(elementsComponents)do
    for componentName, data in pairs(components)do
      removeElementComponent(element, componentName)
    end
  end
end

addEventHandler("onResourceStop", resourceRoot, function()
  clearAllComponents()
end)

setTimer(function()
  local object = createObject(1337,0,0,0)
  addElementComponent(object, "save")
end,500,1)