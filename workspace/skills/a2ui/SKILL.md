---
name: a2ui
description: "Render rich UI cards on the web dashboard using the `canvas` tool. Use for weather, calendar, tasks, news, lists, settings — any response that benefits from visual layout."
always: true
---

# A2UI Skill — Canvas Tool

When a response benefits from **visual UI** (weather, calendar, tasks, lists, news, settings),
use the `canvas` tool to render A2UI cards on the connected web dashboard.

## How to Use

### Push UI Cards
Call the `canvas` tool with:
- `action`: `"a2ui_push"`
- `jsonl`: A2UI JSONL string (one JSON object per line, `\n` separated)

### Clear UI
Call the `canvas` tool with:
- `action`: `"a2ui_reset"`

## Rules
1. **Always reply with text too** — canvas is supplementary; Telegram users only see text
2. Use `surfaceId: "default"` always
3. Every component needs a unique `id`
4. Use `path` references in components, actual values in `dataModelUpdate`
5. JSONL = one JSON object per line, separated by `\n` in the jsonl string
6. For simple chat (greetings, jokes) — do NOT call canvas, text only

## Example: Weather Card (canvas tool call)
```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"content\"}}},{\"id\":\"content\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"temp\",\"detail\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"temp\",\"component\":{\"Text\":{\"text\":{\"path\":\"/temp\"},\"usageHint\":\"h1\"}}},{\"id\":\"detail\",\"component\":{\"Text\":{\"text\":{\"path\":\"/detail\"},\"usageHint\":\"body\"}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"🌤️ Seoul Weather\"},{\"key\":\"temp\",\"valueString\":\"12°C\"},{\"key\":\"detail\",\"valueString\":\"Clear | Wind 3m/s | Humidity 45%\"}]}}"
}
```

## A2UI JSON Schema (Official)

The following is the official A2UI component schema. Use these component types in `surfaceUpdate.components`.

---BEGIN A2UI JSON SCHEMA---

### Server To Client Schema:
{
  "title": "A2UI Message Schema",
  "description": "Describes a JSON payload for an A2UI (Agent to UI) message, which is used to dynamically construct and update user interfaces. A message MUST contain exactly ONE of the action properties: 'beginRendering', 'surfaceUpdate', 'dataModelUpdate', or 'deleteSurface'.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "beginRendering": {
      "type": "object",
      "description": "Signals the client to begin rendering a surface with a root component and specific styles.",
      "additionalProperties": false,
      "properties": {
        "surfaceId": {
          "type": "string",
          "description": "The unique identifier for the UI surface to be rendered."
        },
        "catalogId": {
          "type": "string",
          "description": "The identifier of the component catalog to use for this surface. If omitted, the client MUST default to the standard catalog for this A2UI version (https://a2ui.org/specification/v0_8/standard_catalog_definition.json)."
        },
        "root": {
          "type": "string",
          "description": "The ID of the root component to render."
        },
        "styles": {
          "type": "object",
          "description": "Styling information for the UI.",
          "additionalProperties": true
        }
      },
      "required": [
        "root",
        "surfaceId"
      ]
    },
    "surfaceUpdate": {
      "type": "object",
      "description": "Updates a surface with a new set of components.",
      "additionalProperties": false,
      "properties": {
        "surfaceId": {
          "type": "string",
          "description": "The unique identifier for the UI surface to be updated. If you are adding a new surface this *must* be a new, unique identified that has never been used for any existing surfaces shown."
        },
        "components": {
          "type": "array",
          "description": "A list containing all UI components for the surface.",
          "minItems": 1,
          "items": {
            "type": "object",
            "description": "Represents a *single* component in a UI widget tree. This component could be one of many supported types.",
            "additionalProperties": false,
            "properties": {
              "id": {
                "type": "string",
                "description": "The unique identifier for this component."
              },
              "weight": {
                "type": "number",
                "description": "The relative weight of this component within a Row or Column. This corresponds to the CSS 'flex-grow' property. Note: this may ONLY be set when the component is a direct descendant of a Row or Column."
              },
              "component": {
                "type": "object",
                "description": "A wrapper object that MUST contain exactly one key, which is the name of the component type. The value is an object containing the properties for that specific component.",
                "additionalProperties": true
              }
            },
            "required": [
              "id",
              "component"
            ]
          }
        }
      },
      "required": [
        "surfaceId",
        "components"
      ]
    },
    "dataModelUpdate": {
      "type": "object",
      "description": "Updates the data model for a surface.",
      "additionalProperties": false,
      "properties": {
        "surfaceId": {
          "type": "string",
          "description": "The unique identifier for the UI surface this data model update applies to."
        },
        "path": {
          "type": "string",
          "description": "An optional path to a location within the data model (e.g., '/user/name'). If omitted, or set to '/', the entire data model will be replaced."
        },
        "contents": {
          "type": "array",
          "description": "An array of data entries. Each entry must contain a 'key' and exactly one corresponding typed 'value*' property.",
          "items": {
            "type": "object",
            "description": "A single data entry. Exactly one 'value*' property should be provided alongside the key.",
            "additionalProperties": false,
            "properties": {
              "key": {
                "type": "string",
                "description": "The key for this data entry."
              },
              "valueString": {
                "type": "string"
              },
              "valueNumber": {
                "type": "number"
              },
              "valueBoolean": {
                "type": "boolean"
              },
              "valueMap": {
                "description": "Represents a map as an adjacency list.",
                "type": "array",
                "items": {
                  "type": "object",
                  "description": "One entry in the map. Exactly one 'value*' property should be provided alongside the key.",
                  "additionalProperties": false,
                  "properties": {
                    "key": {
                      "type": "string"
                    },
                    "valueString": {
                      "type": "string"
                    },
                    "valueNumber": {
                      "type": "number"
                    },
                    "valueBoolean": {
                      "type": "boolean"
                    }
                  },
                  "required": [
                    "key"
                  ]
                }
              }
            },
            "required": [
              "key"
            ]
          }
        }
      },
      "required": [
        "contents",
        "surfaceId"
      ]
    },
    "deleteSurface": {
      "type": "object",
      "description": "Signals the client to delete the surface identified by 'surfaceId'.",
      "additionalProperties": false,
      "properties": {
        "surfaceId": {
          "type": "string",
          "description": "The unique identifier for the UI surface to be deleted."
        }
      },
      "required": [
        "surfaceId"
      ]
    }
  }
}

### Catalog Schema:
{
  "components": {
    "Text": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "text": {
          "type": "object",
          "description": "The text content to display. This can be a literal string or a reference to a value in the data model ('path', e.g., '/doc/title'). While simple Markdown formatting is supported (i.e. without HTML, images, or links), utilizing dedicated UI components is generally preferred for a richer and more structured presentation.",
          "additionalProperties": false,
          "properties": {
            "literalString": {
              "type": "string"
            },
            "path": {
              "type": "string"
            }
          }
        },
        "usageHint": {
          "type": "string",
          "description": "A hint for the base text style. One of:\n- `h1`: Largest heading.\n- `h2`: Second largest heading.\n- `h3`: Third largest heading.\n- `h4`: Fourth largest heading.\n- `h5`: Fifth largest heading.\n- `caption`: Small text for captions.\n- `body`: Standard body text.",
          "enum": [
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "caption",
            "body"
          ]
        }
      },
      "required": [
        "text"
      ]
    },
    "Image": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "url": {
          "type": "object",
          "description": "The URL of the image to display. This can be a literal string ('literal') or a reference to a value in the data model ('path', e.g. '/thumbnail/url').",
          "additionalProperties": false,
          "properties": {
            "literalString": {
              "type": "string"
            },
            "path": {
              "type": "string"
            }
          }
        },
        "fit": {
          "type": "string",
          "description": "Specifies how the image should be resized to fit its container. This corresponds to the CSS 'object-fit' property.",
          "enum": [
            "contain",
            "cover",
            "fill",
            "none",
            "scale-down"
          ]
        },
        "usageHint": {
          "type": "string",
          "description": "A hint for the image size and style. One of:\n- `icon`: Small square icon.\n- `avatar`: Circular avatar image.\n- `smallFeature`: Small feature image.\n- `mediumFeature`: Medium feature image.\n- `largeFeature`: Large feature image.\n- `header`: Full-width, full bleed, header image.",
          "enum": [
            "icon",
            "avatar",
            "smallFeature",
            "mediumFeature",
            "largeFeature",
            "header"
          ]
        }
      },
      "required": [
        "url"
      ]
    },
    "Icon": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "name": {
          "type": "object",
          "description": "The name of the icon to display. This can be a literal string or a reference to a value in the data model ('path', e.g. '/form/submit').",
          "additionalProperties": false,
          "properties": {
            "literalString": {
              "type": "string",
              "enum": [
                "accountCircle",
                "add",
                "arrowBack",
                "arrowForward",
                "attachFile",
                "calendarToday",
                "call",
                "camera",
                "check",
                "close",
                "delete",
                "download",
                "edit",
                "event",
                "error",
                "favorite",
                "favoriteOff",
                "folder",
                "help",
                "home",
                "info",
                "locationOn",
                "lock",
                "lockOpen",
                "mail",
                "menu",
                "moreVert",
                "moreHoriz",
                "notificationsOff",
                "notifications",
                "payment",
                "person",
                "phone",
                "photo",
                "print",
                "refresh",
                "search",
                "send",
                "settings",
                "share",
                "shoppingCart",
                "star",
                "starHalf",
                "starOff",
                "upload",
                "visibility",
                "visibilityOff",
                "warning"
              ]
            },
            "path": {
              "type": "string"
            }
          }
        }
      },
      "required": [
        "name"
      ]
    },
    "Row": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "children": {
          "type": "object",
          "description": "Defines the children. Use 'explicitList' for a fixed set of children, or 'template' to generate children from a data list.",
          "additionalProperties": false,
          "properties": {
            "explicitList": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "template": {
              "type": "object",
              "description": "A template for generating a dynamic list of children from a data model list. `componentId` is the component to use as a template, and `dataBinding` is the path to the map of components in the data model. Values in the map will define the list of children.",
              "additionalProperties": false,
              "properties": {
                "componentId": {
                  "type": "string"
                },
                "dataBinding": {
                  "type": "string"
                }
              },
              "required": [
                "componentId",
                "dataBinding"
              ]
            }
          }
        },
        "distribution": {
          "type": "string",
          "description": "Defines the arrangement of children along the main axis (horizontally). This corresponds to the CSS 'justify-content' property.",
          "enum": [
            "center",
            "end",
            "spaceAround",
            "spaceBetween",
            "spaceEvenly",
            "start"
          ]
        },
        "alignment": {
          "type": "string",
          "description": "Defines the alignment of children along the cross axis (vertically). This corresponds to the CSS 'align-items' property.",
          "enum": [
            "start",
            "center",
            "end",
            "stretch"
          ]
        }
      },
      "required": [
        "children"
      ]
    },
    "Column": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "children": {
          "type": "object",
          "description": "Defines the children. Use 'explicitList' for a fixed set of children, or 'template' to generate children from a data list.",
          "additionalProperties": false,
          "properties": {
            "explicitList": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "template": {
              "type": "object",
              "description": "A template for generating a dynamic list of children from a data model list. `componentId` is the component to use as a template, and `dataBinding` is the path to the map of components in the data model. Values in the map will define the list of children.",
              "additionalProperties": false,
              "properties": {
                "componentId": {
                  "type": "string"
                },
                "dataBinding": {
                  "type": "string"
                }
              },
              "required": [
                "componentId",
                "dataBinding"
              ]
            }
          }
        },
        "distribution": {
          "type": "string",
          "description": "Defines the arrangement of children along the main axis (vertically). This corresponds to the CSS 'justify-content' property.",
          "enum": [
            "start",
            "center",
            "end",
            "spaceBetween",
            "spaceAround",
            "spaceEvenly"
          ]
        },
        "alignment": {
          "type": "string",
          "description": "Defines the alignment of children along the cross axis (horizontally). This corresponds to the CSS 'align-items' property.",
          "enum": [
            "center",
            "end",
            "start",
            "stretch"
          ]
        }
      },
      "required": [
        "children"
      ]
    },
    "Card": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "child": {
          "type": "string",
          "description": "The ID of the component to be rendered inside the card."
        }
      },
      "required": [
        "child"
      ]
    },
    "Divider": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "axis": {
          "type": "string",
          "description": "The orientation of the divider.",
          "enum": [
            "horizontal",
            "vertical"
          ]
        }
      }
    },
    "Button": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "child": {
          "type": "string",
          "description": "The ID of the component to display in the button, typically a Text component."
        },
        "primary": {
          "type": "boolean",
          "description": "Indicates if this button should be styled as the primary action."
        },
        "action": {
          "type": "object",
          "description": "The client-side action to be dispatched when the button is clicked. It includes the action's name and an optional context payload.",
          "additionalProperties": false,
          "properties": {
            "name": {
              "type": "string"
            },
            "context": {
              "type": "array",
              "items": {
                "type": "object",
                "additionalProperties": false,
                "properties": {
                  "key": {
                    "type": "string"
                  },
                  "value": {
                    "type": "object",
                    "description": "Defines the value to be included in the context as either a literal value or a path to a data model value (e.g. '/user/name').",
                    "additionalProperties": false,
                    "properties": {
                      "path": {
                        "type": "string"
                      },
                      "literalString": {
                        "type": "string"
                      },
                      "literalNumber": {
                        "type": "number"
                      },
                      "literalBoolean": {
                        "type": "boolean"
                      }
                    }
                  }
                },
                "required": [
                  "key",
                  "value"
                ]
              }
            }
          },
          "required": [
            "name"
          ]
        }
      },
      "required": [
        "child",
        "action"
      ]
    }
  },
  "styles": {
    "font": {
      "type": "string",
      "description": "The primary font for the UI."
    },
    "primaryColor": {
      "type": "string",
      "description": "The primary UI color as a hexadecimal code (e.g., '#00BFFF').",
      "pattern": "^#[0-9a-fA-F]{6}$"
    }
  },
  "catalogId": "https://a2ui.org/specification/v0_8/standard_catalog_definition.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema"
}

---END A2UI JSON SCHEMA---

## Additional Examples

### Calendar List
```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"col\"}}},{\"id\":\"col\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"e1\",\"e2\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"e1\",\"component\":{\"Text\":{\"text\":{\"path\":\"/ev1\"},\"usageHint\":\"body\"}}},{\"id\":\"e2\",\"component\":{\"Text\":{\"text\":{\"path\":\"/ev2\"},\"usageHint\":\"body\"}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"📅 Today's Schedule\"},{\"key\":\"ev1\",\"valueString\":\"09:00 Team Standup\"},{\"key\":\"ev2\",\"valueString\":\"14:00 1:1 Meeting\"}]}}"
}
```

### Button Selection
```json
{
  "action": "a2ui_push",
  "jsonl": "{\"beginRendering\":{\"surfaceId\":\"default\",\"root\":\"root\"}}\n{\"surfaceUpdate\":{\"surfaceId\":\"default\",\"components\":[{\"id\":\"root\",\"component\":{\"Card\":{\"child\":\"col\"}}},{\"id\":\"col\",\"component\":{\"Column\":{\"children\":{\"explicitList\":[\"title\",\"btn1\",\"btn2\"]}}}},{\"id\":\"title\",\"component\":{\"Text\":{\"text\":{\"path\":\"/title\"},\"usageHint\":\"h2\"}}},{\"id\":\"btn1\",\"component\":{\"Button\":{\"child\":\"btn1-t\",\"primary\":true,\"action\":{\"name\":\"select\",\"context\":[{\"key\":\"choice\",\"value\":{\"path\":\"/o1\"}}]}}}},{\"id\":\"btn1-t\",\"component\":{\"Text\":{\"text\":{\"path\":\"/o1\"}}}},{\"id\":\"btn2\",\"component\":{\"Button\":{\"child\":\"btn2-t\",\"action\":{\"name\":\"select\",\"context\":[{\"key\":\"choice\",\"value\":{\"path\":\"/o2\"}}]}}}},{\"id\":\"btn2-t\",\"component\":{\"Text\":{\"text\":{\"path\":\"/o2\"}}}}]}}\n{\"dataModelUpdate\":{\"surfaceId\":\"default\",\"path\":\"/\",\"contents\":[{\"key\":\"title\",\"valueString\":\"🍽️ What to eat?\"},{\"key\":\"o1\",\"valueString\":\"🍗 Chicken\"},{\"key\":\"o2\",\"valueString\":\"🍕 Pizza\"}]}}"
}
```
