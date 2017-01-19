# JSON schema guide

This is a reference for the JSON schema provided by Matrioska, which should be followed in order to register `Component`s and build the provided standard components.

## JSON schemas for `Component` and `ComponentMeta`

Below you can find a detailed schema for `Component`s and for each configuration (`ComponentMeta`).

### Component schema

| Key | Type | Description |
| --- | ---- | ----------- |
| `type` | `String` | The type of the component. Used for factory registration. |

### StackConfig schema

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `title` | `String` | The title of the stack. | `title` | Yes | `nil` |
| `spacing` | `Float` | The spacing of the components inside the stack. | `spacing` | Yes | `10` |
| `axis` | `Int` | The orientation of the stack. Can be either `0`(horizontal) or `1`(vertical). | `axis` | Yes | `1` |
| `preserve_parent_width` | `Bool` | Whether the arranged subviews should preserve the parent width or their own intrinsicContentSize. | `preserveParentWidth` | Yes | `false` |
| `background_color` | `String` | The background color of the stack. Alpha and compact forms are not supported. Valid formats: `0x123456` or `123456`. | `backgroundColor` | Yes | `ffffff`(white) |

### TabBarConfig schema

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `selected_index` | `Int` | The selected index of the tab bar. | `selectedIndex` | No | . |

### Tab schema

| Key | Type | Description | Maps to | Optional | Default value |
| --- | ---- | ----------- | ------- | -------- | ------------- |
| `title` | `String` | The title to display on the tab. | `title` | No | . |
| `icon_name` | `Int` | The name of the icon to display on the tab. | `iconName` | No | . |

## Example JSON

```
{
	"structure": {
		"type": "tabbar",
		"meta": {
			"selectedIndex": 1
		},
		"children": [{
			"type": "navigation",
			"meta": {
				"title": "history_title",
				"iconName": "history_tab_icon"
			},
			"children": [{
				"type": "stack",
				"meta": {
          "axis": 1,
          "preserveParentWidth": true,
          "backgroundColor": "0x123456"
				},
				"children": [{
					"type": "table_view"
				}]
			}]
		}, {
			"type": "navigation",
			"meta": {
				"title": "main_tab_title",
				"iconName": "main_tab_icon"
			},
			"children": [{
				"type": "stack",
				"meta": {
					"axis": 1,
          "title": "Main stack",
          "preserveParentWidth": true,
					"spacing": "5"
				},
				"children": [{
					"type": "label",
					"meta": {
					}
				}, {
					"type": "test_feature",
					"meta": {
					}
				}
			]
			}]
		}]
	}
}
```
